Names starting with `priv_` are gitignored.

Create like so

```bash
darp> ssh-keygen -f net/priv_github_cd_ssh -t ed25519 -C "github-cd"
```

Note: iad is Ashburn Virginia, guessing might be near github server
and if not Eastern US is an ok default.

```bash
darp> flyctl wireguard create danielzfranklin iad niss-github-cd
```

[When prompted enter name `priv_wg_for_cd`]

Note: dwf is Dallas, what flyctl picked as closest to
my home in Nov 2021

```bash
darp> flyctl wireguard create danielzfranklin dfw niss-local
```

[When prompted enter name `priv_wg_for_local`]

