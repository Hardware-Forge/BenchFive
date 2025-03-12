.PHONY: all clean run getresultscyclictest getresultscoremark

#ignorare benchmark-list/cyclictest l'ho fatto solo per capire come costruire un makefile con piu benchmark


#directory di output
BIN_DIR := bin


all: cyclictest coremark

# Build per ogni benchmark
cyclictest:
	$(MAKE) -C benchmark-list/cyclictest all

coremark:
	$(MAKE) -C benchmarks/CPU/coremark

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmark-list/cyclictest clean
	$(MAKE) -C benchmarks/CPU/coremark clean
	rm -rf $(BIN_DIR)/*

# Esecuzione cyclictest e raccolta risultati
getresultscyclictest:
	$(MAKE) -C benchmark-list/cyclictest run &
	@sleep 5
	echo "test"
	$(MAKE) -C benchmark-list/cyclictest print
	@pkill -f cyclictest

# Esecuzione di CoreMark e raccolta risultati in bin
getresultscoremark: | $(BIN_DIR)
	$(MAKE) -C benchmarks/CPU/coremark run > $(BIN_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(BIN_DIR)/coremark_results.txt"

# Creazione directory bin nel caso venisse cancellata
$(BIN_DIR):
	mkdir -p $(BIN_DIR)
