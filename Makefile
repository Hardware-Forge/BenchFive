# serve ad avere accesso a tutti i file in una cartella, in questo caso a tutti i file in cyclictest
FILES = $(wildcard cyclictest/*)

CC = gcc
CFLAGS = -Wall -D_GNU_SOURCE -I.
LDFLAGS = -lnuma

#definisco il perscorso corretto per i file
SRCDIR = cyclictest
#definisco il percorso corretto per i file oggetto, cioè dove voglio che vengano salvati
OBJDIR = cyclictest
objects = $(OBJDIR)/cyclictest.o $(OBJDIR)/rt-numa.o $(OBJDIR)/rt-error.o $(OBJDIR)/rt-utils.o 

all: risultato

$(OBJDIR)cyclictest.o: $(SRCDIR)/cyclictest.c $(SRCDIR)/rt-numa.h $(SRCDIR)/rt-error.h $(SRCDIR)/utils.h $(SRCDIR)/rt_numa.h $(SRCDIR)/bionic.h
	$(CC) -c /cyclictest.c $(CFLAGS)

$(OBJDIR)rt-numa.o: $(SRCDIR)/rt-numa.c $(SRCDIR)/rt-numa.h $(SRCDIR)/rt-error.h
	$(CC) -c /rt-numa.c $(CFLAGS)
	
$(OBJDIR)rt-error.o: $(SRCDIR)/rt-error.c $(SRCDIR)/rt-error.h
	$(CC) -c /rt-error.c $(CFLAGS)

$(OBJDIR)rt-utils.o: $(SRCDIR)/rt-utils.c $(SRCDIR)/rt-utils.h $(SRCDIR)/rt-error.h $(SRCDIR)/rt-sched.h
	$(CC) -c /rt-utils.c $(CFLAGS)



risultato: $(objects)
	$(CC) -o risultato $(objects) $(CFLAGS) $(LDFLAGS)

clean: 
	rm -f $(OBJDIR)/*.o risultato
# -f serve a non far printare l'errore se non trova il file,* serve a cancellare tutti i file con estensione .o
# in questo caso cancella tutti i file con estensione .o nella cartella cyclictest
run: risultato
	@./risultato -a -t -N -p99
# la chiocciola serve a non fare printare il comando a schermo, make di base printa tutto a schermo

snapshot: @python3 $(SRCDIR)/get_cyclictest_snapshot.py --snapshot

list: @python3 $(SRCDIR)/get_cyclictest_snapshot.py --list

print: @python3 $(SRCDIR)/get_cyclictest_snapshot.py --print