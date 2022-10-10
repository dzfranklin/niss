use std::ffi::c_int;

pub(crate) mod prelude;
pub(crate) mod store;
pub mod unit;

pub use store::setup_sqlite_error_logging;

use prelude::*;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Display, Error, Debug)]
/// groceries: {0}
pub struct Error(#[from] ErrorRepr);

macro_rules! impl_error_repr {
    ([$($variant:ident => $from:path),*$(,)?]) => {
        #[derive(Error, Debug)]
        #[error(transparent)]
        pub(crate) enum ErrorRepr {
            $(
                $variant(#[from] $from),
            )*
        }

        $(
            impl From<$from> for Error {
                fn from(val: $from) -> Self {
                    ErrorRepr::from(val).into()
                }
            }
        )*
    };
}

impl_error_repr!([Store => store::Error,]);
