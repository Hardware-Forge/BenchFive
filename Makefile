.PHONY: all clean run snapshot list print
all:
	$(MAKE) -C benchmark-list/cyclictest all
clean:
	$(MAKE) -C benchmark-list/cyclictest clean
getresultscyclictest:
	$(MAKE) -C benchmark-list/cyclictest run &
	@sleep 5
	echo "test"
	$(MAKE)  -C benchmark-list/cyclictest print
	@pkill -f cyclictest
	