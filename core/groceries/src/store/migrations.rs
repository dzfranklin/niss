use rusqlite_migration::{Migrations, M};

macro_rules! _impl_sql {
    // "Outputs something like `"migrations/db/042_do_a_thing.up.sql"`
    ($parent:literal, $name:literal, $direction:literal) => {{
        include_str!(concat!(
            "migrations/",
            $parent,
            "/",
            $name,
            ".",
            $direction,
            ".sql"
        ))
    }};
}

macro_rules! _impl {
    ($parent:literal, [$($name:literal,)*]) => {{
        Migrations::new(vec![
            $({
                M::up(_impl_sql!($parent, $name, "up"))
                    .down(_impl_sql!($parent, $name, "down"))
            })*
        ])
    }};
}

// NOTE:
// - Remember we don't atomically migrate db & cache together
// - The prefix

pub(crate) fn db() -> Migrations<'static> {
    _impl!("db", ["001_init",])
}

pub(crate) fn cache() -> Migrations<'static> {
    _impl!("cache", ["001_init",])
}
