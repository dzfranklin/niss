use rusqlite::Row;

use crate::prelude::*;

#[derive(Debug, Display, Error)]
#[prefix_enum_doc_attributes]
/// event
pub(crate) enum Error {
    /// decode: {0} version {1} unrecognized
    Unrecognized(String, u64),
    /// data encode: {0}
    DataEncode(postcard::Error),
    /// data decode: {0}
    DataDecode(postcard::Error),
    /// sequence denominator is zero
    SeqDenomZero,
}

#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Event {
    pub(crate) uuid: Uuid,
    pub(crate) seq: Seq,
    pub(crate) data: Data,
}

#[derive(Debug, Clone, Eq, PartialEq, Ord, PartialOrd, Hash)]
pub(crate) struct Seq(num_rational::Ratio<u64>);

#[derive(Debug, Clone, PartialEq)]
pub(crate) enum Data {
    AddStoreV1(AddStoreV1),
    BuyV1(BuyV1),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub(crate) struct AddStoreV1 {
    uuid: Uuid,
    name: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub(crate) struct BuyV1 {
    store: Uuid,
    where_in_store: String,
    product: String,
    price: Dollars,
}

const EVENT_ADD_STORE: &str = "add_store";
const EVENT_BUY: &str = "buy";

impl Data {
    pub(crate) fn event(&self) -> (&'static str, u64) {
        match self {
            Data::AddStoreV1(_) => (EVENT_ADD_STORE, 1),
            Data::BuyV1(_) => (EVENT_BUY, 1),
        }
    }

    pub(crate) fn serialize(&self) -> Result<Vec<u8>, Error> {
        use postcard::to_stdvec;

        match self {
            Data::AddStoreV1(data) => to_stdvec(data),
            Data::BuyV1(data) => to_stdvec(data),
        }
        .map_err(Error::DataEncode)
    }

    pub(crate) fn deserialize(event: &str, version: u64, data: &[u8]) -> Result<Self, Error> {
        use postcard::from_bytes;
        use Data as D;

        match (event, version) {
            (EVENT_BUY, 1) => from_bytes(data).map(D::BuyV1).map_err(Error::DataDecode),
            _ => Err(Error::Unrecognized(event.to_owned(), version)),
        }
    }
}

impl Seq {
    pub(crate) fn new(p: u64, q: u64) -> Result<Self, Error> {
        if q == 0 {
            Err(Error::SeqDenomZero)
        } else {
            Ok(Self(num_rational::Ratio::new(p, q)))
        }
    }
}
