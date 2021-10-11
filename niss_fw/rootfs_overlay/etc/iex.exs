NervesMOTD.print()

# Add Toolshed helpers to the IEx session
use Toolshed

RingLogger.attach(level: :info)
RingLogger.tail(level: :info)
