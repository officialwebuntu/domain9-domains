CREATE TABLE domains (
    id INTEGER PRIMARY KEY,
    domain_name VARCHAR(255) NOT NULL,
    registrant_name VARCHAR(255),
    registrant_email VARCHAR(255),
    dns_records TEXT,
    expiration_date DATE
);
