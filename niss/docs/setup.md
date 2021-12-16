# Setting up

## Create db cluster

```bash
darp> fly pg create
```

## Set secrets

Read each line in `niss ui secrets` 1password note and set like so.

```bash
darp> fly secrets set <KEY>=<VALUE>
```

## Establish system-wide creds for ssh

```bash
darp> fly ssh establish
darp> fly ssh issue --agent
```

## Create db

Doing this manually as `fly pg attach` was/is broken. See <https://community.fly.io/t/reattach-the-database/3261/12>

Connect via `fly ssh console` to niss. Get the connection url from the output
of `fly pg create` run previously and stored in 1password.

```bash
niss> psql <CONN_URL>
psql> CREATE DATABASE niss;
psql> CREATE USER niss WITH LOGIN PASSWORD '<password>';
psql> GRANT ALL PRIVILEGES ON DATABASE niss TO niss;
```

Create the ui db connection url using the template

```text
postgres://niss:<password>@niss-db.internal:5432/niss
```

Test the connection string via

```bash
niss> psql <UI_CONN_URL>
```

Store the connection url in `niss ui secrets` 1password note and with

```bash
darp> fly secrets set UI_CONN_URL=<UI_CONN_URL>
```

## Setup domain

Find ips with `fly ips list`. Create A record for niss.danielzfranklin.org with v4 and AAAA with v6.

Create SSL cert with `fly certs create niss.danielzfranklin.org`.

Wait until `fly certs show niss.danielzfranklin.org` shows it's issued.

Visit <https://niss.danielzfranklin.org/> and check it loads with a valid cert.
