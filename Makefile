.PHONY: all clean run getresultscyclictest getresultscoremark rt-tests run_hackbench hackbench

#ignorare benchmark-list/cyclictest l'ho fatto solo per capire come costruire un makefile con piu benchmark


#directory di output
BIN_DIR := bin
RESULTS_DIR := results


all: cyclictest coremark

coremark:
	$(MAKE) -C benchmarks/CPU/coremark

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmark-list/cyclictest clean
	$(MAKE) -C benchmarks/CPU/coremark clean
	rm -rf $(BIN_DIR)/*

# Esecuzione di CoreMark e raccolta risultati in bin
getresultscoremark: | $(BIN_DIR)
	$(MAKE) -C benchmarks/CPU/coremark run > $(BIN_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(BIN_DIR)/coremark_results.txt"

# Creazione directory bin nel caso venisse cancellata
$(BIN_DIR):
	mkdir -p $(BIN_DIR)
# Creazione directory results nel caso venisse cancellata
$(RESULTS_DIR):
	mkdir -p $(RESULTS_DIR)

rt-tests: $(BIN_DIR) #mi assicuro esista la cartella prima di eseguire il make
	$(MAKE) -C benchmarks/syslevel/rt-tests all
	find benchmarks/syslevel/rt-tests -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \; 
# trovo tutti i file eseguibili e li copio nella cartella bin 
#Esecuzione di hackbench
run_hackbench:
	@benchmarks/syslevel/rt-tests/hackbench > results.txt
#Esecuzione di hwlatdetect
run_hwlatdetect:
	@benchmarks/syslevel/rt-tests/hwlatdetect
#Esecuzione di deadline_test
run_deadline_test:
	@benchmarks/syslevel/rt-tests/deadline_test
#Esecuzione di cyclictest
run_cyclictest:
	@benchmarks/syslevel/rt-tests/cyclictest
#Esecuzione di get_cyclictest_snapshot
run_get_cyclictest_snapshot:
	@benchmarks/syslevel/rt-tests/get_cyclictest_snapshot
# Esecuzione cyclictest e raccolta risultati,non funziona bene
getresultscyclictest:
	$(MAKE) run_cyclictest & 
	@sleep 1
	$(MAKE) get_cyclictest_snapshot
	@sleep 1

fio:
	@benchmarks/IO/fio/configure
	$(MAKE) -C benchmarks/IO/fio all
	$(MAKE) -C benchmarks/IO/fio install
	$(MAKE) create_fio_file

create_fio_file:
	@printf "[global]\nioengine=libaio\ndirect=1\nbs=4k\nsize=10M\nruntime=120\ngroup_reporting\nunlink=1\n\n\
	[seq-read]\nrw=read\nnumjobs=2\n\n\
	[seq-write]\nrw=write\nnumjobs=2\n\n\
	[rand-read]\nrw=randread\nnumjobs=4\n\n\
	[rand-write]\nrw=randwrite\nnumjobs=4\n\n\
	[mixed-rw]\nrw=randrw\nrwmixread=70\nnumjobs=4\n" > benchmarks/IO/fio/config.fio
	@rm -f benchmarks/IO/fio/testfile*

fio_run:
	@fio benchmarks/IO/fio/config.fio
