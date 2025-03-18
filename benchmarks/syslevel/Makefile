



#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: rt-tests

run_all: run_hackbench run_hwlatdetect run_deadline_test run_cyclictest rungetresultscyclictest

rt-tests: $(BIN_DIR) #mi assicuro esista la cartella prima di eseguire il make
	(cd rt-tests && $(MAKE) all)
	find rt-tests -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \; 

#Esecuzione di hackbench
run_hackbench: | $(RESULTS_DIR)
	@rt-tests/hackbench > $(RESULTS_DIR)/hackbench_results.txt
#Esecuzione di hwlatdetect
run_hwlatdetect:
	@rt-tests/hwlatdetect > $(RESULTS_DIR)/hwlatdetect_results.txt
#Esecuzione di deadline_test
run_deadline_test:
	@rt-tests/deadline_test > $(RESULTS_DIR)/deadline_test_results.txt
#è uno stress test, non da risultati
run_pip_stress:
	@rt-tests/pi_stress
#Esecuzione di cyclictest
run_cyclictest:
	@rt-tests/cyclictest -a -t -N -p99
#Esecuzione di get_cyclictest_snapshot
run_get_cyclictest_snapshot:
	@rt-tests/get_cyclictest_snapshot > $(RESULTS_DIR)/cyclictest_results.txt
# Esecuzione cyclictest e raccolta risultati,non funziona bene
getresultscyclictest:
	tmux new-session -d -s cyclictest_session 'rt-tests/cyclictest -a -t -N -p99'
	sleep 3
	@rt-tests/get_cyclictest_snapshot > $(RESULTS_DIR)/cyclictest_results.txt
	sleep 3
	tmux kill-session -t cyclictest_session
	@echo "Risultati di Cyclictest salvati in $(RESULTS_DIR)/cyclictest_results.txt"


clean:
	$(MAKE) -C rt-tests clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

