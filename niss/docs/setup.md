# Setting up

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

## Setup db

Based on <https://fly.io/docs/getting-started/multi-region-databases/>.

```bash
darp> fly pg create
```

Provide the name `niss-db`, set the region `dfw` (we want the primary to be close to niss-local),
and select a custom size and enter the least powerful specs possibly for a production setup with 2GB
of storage. (We need to select production to get a replication-capable setup).

Save the config

```bash
darp> mkdir -p niss/db
darp> cd niss/db
darp> fly config save --app niss-db
```

Edit fly.toml to add the section

```toml
[build]
  image = "flyio/postgres:14"
```

(You can check that version 14 is appropriate with `fly image show -a niss-db`)

Create volumes in every region we want a replica, eg:

```bash
darp niss/db> fly volumes create pg_data --size 2 --region cdg
```

Scale so that we have one server in each region (by default we'll have a primary and a replica in
the primary region, which we don't need for redundancy if there are other regions with replicas).

```bash
darp niss/db> fly scale count 2 # Assumes one primary and one replica region
```

Attach

```bash
darp niss/db> fly pg attach
```

Test we can connect to primaries and replicas. SSH into the primary and a replica and check that
`Fly.Postgres.database_url()` contains the region in the url. Try a read and a write in each.

## Setup domain

Find ips with `fly ips list`. Create A record for niss.danielzfranklin.org with v4 and AAAA with v6.

Create SSL cert with `fly certs create niss.danielzfranklin.org`.

Wait until `fly certs show niss.danielzfranklin.org` shows it's issued.

Visit <https://niss.danielzfranklin.org/> and check it loads with a valid cert.
