# serve ad avere accesso a tutti i file in una cartella, in questo caso a tutti i file in src
FILES = $(wildcard src/*)

CC = gcc
CFLAGS = -Wall -D_GNU_SOURCE -I.
LDFLAGS = -lnuma

#definisco il perscorso corretto per i file
SRCDIR = src
#definisco il percorso corretto per i file oggetto, cioè dove voglio che vengano salvati
OBJDIR = src
EXECDIR = ../../bin/
objects = $(OBJDIR)/cyclictest.o $(OBJDIR)/rt-numa.o $(OBJDIR)/rt-error.o $(OBJDIR)/rt-utils.o 

all: $(EXECDIR)cyclictest

$(OBJDIR)src.o: $(SRCDIR)/cyclictest.c $(SRCDIR)/rt-numa.h $(SRCDIR)/rt-error.h $(SRCDIR)/utils.h $(SRCDIR)/rt_numa.h $(SRCDIR)/bionic.h
	$(CC) -c /src.c $(CFLAGS)

$(OBJDIR)rt-numa.o: $(SRCDIR)/rt-numa.c $(SRCDIR)/rt-numa.h $(SRCDIR)/rt-error.h
	$(CC) -c /rt-numa.c $(CFLAGS)
	
$(OBJDIR)rt-error.o: $(SRCDIR)/rt-error.c $(SRCDIR)/rt-error.h
	$(CC) -c /rt-error.c $(CFLAGS)

$(OBJDIR)rt-utils.o: $(SRCDIR)/rt-utils.c $(SRCDIR)/rt-utils.h $(SRCDIR)/rt-error.h $(SRCDIR)/rt-sched.h
	$(CC) -c /rt-utils.c $(CFLAGS)



$(EXECDIR)cyclictest: $(objects)
	$(CC) -o $(EXECDIR)cyclictest $(objects) $(CFLAGS) $(LDFLAGS)

clean: 
	rm -f $(OBJDIR)/*.o $(EXECDIR)cyclictest
# -f serve a non far printare l'errore se non trova il file,* serve a cancellare tutti i file con estensione .o
# in questo caso cancella tutti i file con estensione .o nella cartella src
run: $(EXECDIR)cyclictest
	@$(EXECDIR)cyclictest -t -N -p99
# la chiocciola serve a non fare printare il comando a schermo, make di base printa tutto a schermo

snapshot:
	@python3 $(SRCDIR)/get_cyclictest_snapshot.py --snapshot

list:
	@python3 $(SRCDIR)/get_cyclictest_snapshot.py --list
#non funziona bene siccome restituisce un solo PID (credo quello del processo stesso) e non i PID dei processi figli

print:
	@python3 $(SRCDIR)/get_cyclictest_snapshot.py --print