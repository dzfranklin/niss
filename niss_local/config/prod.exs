import Config

config :libcluster,
  debug: true,
  topologies: [
    fly6pn: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        query: "niss_ui.internal",
        node_basename: "niss_ui"
      ]
    ]
  ]
