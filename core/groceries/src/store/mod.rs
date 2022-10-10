pub(crate) mod event;
mod migrations;

use std::{ffi::c_int, time::Duration};

use self::event::{Event, Seq};
use crate::prelude::*;

use rusqlite::Connection as Conn;

const DB_FILENAME: &str = "db.sqlite";
const CACHE_FILENAME: &str = "cache.sqlite";

/// Logs sqlite errors at [`tracing::Level::WARN`]
///
/// # Safety
///
/// You must uphold the safety invariants of [`rusqlite::trace::config_log`].
pub unsafe fn setup_sqlite_error_logging() -> crate::Result<()> {
    rusqlite::trace::config_log(Some(|code: c_int, msg: &str| {
        warn!("sqlite error {}: {}", code, msg);
    }))
    .map_err(|e| Error::Rusqlite(e).into())
}

#[derive(Debug, Display, Error)]
#[prefix_enum_doc_attributes]
/// store
pub(crate) enum Error {
    /// db: {0}
    Rusqlite(#[from] rusqlite::Error),
    /// db: {0}
    Migration(#[from] rusqlite_migration::Error),
    /// {0}
    Event(#[from] event::Error),
}

pub struct Store {
    dir: PathBuf,
    db: Conn,
    cache: Conn,
}

impl Store {
    pub fn new(dir: PathBuf) -> crate::Result<Self> {
        let mut db = Conn::open(&dir.join(DB_FILENAME)).map_err(Error::from)?;
        let mut cache = Conn::open(&dir.join(CACHE_FILENAME)).map_err(Error::from)?;

        // NOTE: We don't attempt to atomically migrate db & cache together
        migrations::db().to_latest(&mut db).map_err(Error::from)?;
        migrations::cache()
            .to_latest(&mut cache)
            .map_err(Error::from)?;

        if tracing::enabled!(tracing::Level::TRACE) {
            conn_setup_trace(&mut db);
            conn_setup_trace(&mut cache);
        }

        Ok(Self { dir, db, cache })
    }

    fn list_events(&self, after: Seq, to_incl: Seq) -> crate::Result<Vec<Event>> {
        self.db
            .prepare("SELECT uuid, seq_p, seq_q, event, data_version, data FROM events WHERE TODO")
            .map_err(Error::from)?
            .query([])
            .map_err(Error::from)?
            .mapped(|row| {
                let uuid = row.get_ref(0)?.as_blob()?;
                let uuid = Uuid::from_slice(uuid).map_err(from_sql_err_helper)?;

                let seq_p: u64 = row.get(1)?;
                let seq_q: u64 = row.get(2)?;
                let seq = Seq::new(seq_p, seq_q).map_err(from_sql_err_helper)?;

                let event_name = row.get_ref(3)?.as_str()?;
                let data_version: u64 = row.get(4)?;
                let data = row.get_ref(5)?.as_blob()?;

                let data = event::Data::deserialize(event_name, data_version, data)
                    .map_err(from_sql_err_helper)?;

                Ok(Event { uuid, seq, data })
            });

        todo!()
    }
}

fn from_sql_err_helper(err: impl std::error::Error + Send + Sync + 'static) -> rusqlite::Error {
    debug!(
        "Faking rusqlite::Error::FromSqlConversionFailure for: {}",
        err
    );
    rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Null, Box::new(err))
}

#[allow(unused)] // We conditionally use it w/ tracing::enabled!
fn conn_setup_trace(conn: &mut Conn) {
    conn.trace(Some(|msg: &str| {
        trace!("sqlite trace: {}", msg);
    }));
    conn.profile(Some(|msg: &str, dur: Duration| {
        trace!("sqlite profile: {:?} {}", dur, msg);
    }));
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_new() -> Result<()> {
        test_init();
        let dir = tempdir()?;
        let _store = Store::new(dir.into_path())?;
        Ok(())
    }
}
