#![allow(unused)]

// Pub & Crate
pub use crate::unit::*;

// Crate

pub(crate) use std::path::PathBuf;

pub(crate) use displaydoc::Display;
pub(crate) use serde::{Deserialize, Serialize};
pub(crate) use thiserror::Error;
pub(crate) use tracing::{debug, error, info, instrument, trace, warn};
pub(crate) use uuid::Uuid;

// Crate test

#[cfg(test)]
mod test {
    pub(crate) use color_eyre::Result;
    pub(crate) use tempfile::{tempdir, tempfile};

    /// # Safety
    ///
    /// Since this is only used in internal tests it's marked safe for
    /// convenience. It isn't.
    ///
    /// `test_init` may only be the very first call of a test.
    pub(crate) fn test_init() {
        unsafe {
            crate::setup_sqlite_error_logging();
        }

        color_eyre::install().unwrap();
    }
}

#[cfg(test)]
pub(crate) use test::*;
