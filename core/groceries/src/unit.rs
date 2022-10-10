use crate::prelude::*;

macro_rules! _impl {
    ($($decl:item)*) => {
        $(
            #[derive(Debug, Clone, PartialEq, PartialOrd, Serialize, Deserialize)]
            #[repr(transparent)]
            $decl
        )*
    };
}

_impl! {
    pub struct Dollars(pub f64);
    pub struct Grams(pub f64);
}
