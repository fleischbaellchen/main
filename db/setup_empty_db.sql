-- Sets up a new database with the schema drawn in `ER_and_Relations.jpg`
-- 
-- David Keller, 11.10.2014
--

PRAGMA foreign_keys=OFF; -- don't enforce foreign keys

create table Category (
    categoryName TEXT PRIMARY KEY
);

create table Product (
    EAN             INTEGER PRIMARY KEY,
    name            TEXT,
    creationDate    INTEGER,
    mainCategory    TEXT, 
    FOREIGN KEY(mainCategory) REFERENCES Category(categoryName)
);

create table ShoppingList (
    listId          INTEGER,
    EAN             TEXT,
    tickedOff       INTEGER,
    addedDate       INTEGER,
    PRIMARY KEY(listId, EAN),
    FOREIGN KEY(EAN) REFERENCES Product(EAN)
);