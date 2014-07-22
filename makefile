CC=i386-elf-gcc 
LIN=i386-elf-ld 
LDFLAGS=--oformat=binary -Ttext=0 
SOURCE=src/BootSector.s 
OBJF=build/AAnotherTest.o 
DEST=build/AAnotherTest.bin 

all: clean 
	$(CC) -c $(SOURCE) -o $(OBJF) 
	$(LIN) $(OBJF) -o $(DEST) $(LDFLAGS) 
	
clean: 
	rm -f $(OBJF) $(DEST) 

