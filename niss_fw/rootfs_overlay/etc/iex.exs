NervesMOTD.print()

# Add Toolshed helpers to the IEx session
use Toolshed

RingLogger.attach()
RingLogger.tail(level: :warn)
