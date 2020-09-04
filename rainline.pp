


    Program Rainline;
    uses    Crt;



    type
        memType = array [Word] of Word;



    var
        memory:         memType;
        userCommand:    Char;
        threadIterator: Word;



    procedure createThread( location: Word );
    var
        here: Word;
    begin

        { find an empty location for the new thread }
        here := 0;

        { while there's a thread here }
        while ( memory[here] > 0 )

        { and this thread's not marked as terminated }
        and ( here <> memory[here] )

        { keep searching }
        do here += 1;
        
        { then create new thread here }
        memory[here] := location;

    end;



    procedure stepThread;
    var
        address:        Word;
        source:         Word;
        destination:    Word;
        fork:           Word;
    begin

        address :=      memory[threadIterator];

        source :=       memory[address];
        destination :=  memory[address+1];
        fork :=         memory[address+2];

        if source <> destination then
        begin

            { copy content of address A to address B }
            memory[destination] := memory[source];

            { let parent jump to the next instruction }
            memory[threadIterator] += 3;

            { fork if it's not where parent is }
            if fork <> memory[threadIterator] then createThread(fork);

        end else
        
            { mark this thread as terminated }
            memory[threadIterator] := threadIterator;

    end;



    procedure step;
    begin

        threadIterator := 0;
        
        while memory[threadIterator] > 0 do
        begin

            { if this thread is not marked as terminated }
            if memory[threadIterator] <> threadIterator then
            
                stepThread;

            threadIterator += 1;
        end;
    end;



    procedure input;
    var
        address:        Word;
        source:         Word;
        destination:    Word;
        fork:           Word;
    begin

        write('Address ');
        readln(address);

        if address mod 3 <> 0 then

            writeln('Error: Wrong alignment')

        else begin

            write('Source Destination Fork (space-separated) ');
            readln(source, destination, fork);

            memory[address] :=      source;
            memory[address + 1] :=  destination;
            memory[address + 2] :=  fork;
        end;
    end;



    procedure wordInput;
    var
        address: Word;
        content: Word;
    begin

        write('Address Content (space-separated) ');
        readln(address, content);

        memory[address] := content;
    end;



    procedure output;
    var
        start:  Word;
        length: Word;
        i:      Word;
        addr:   Word;
    begin

        write('Dump-start ');
        readln(start);

        write('Dump-length ');
        readln(length);

        if start mod 3 <> 0 then

            writeln('Error: Wrong alignment')

        else for i := 0 to length - 1 do begin

            addr := start + i * 3;
            writeln(
                '  [',
                addr,
                ']  Source:',
                memory[addr],
                '  Destination:',
                memory[addr + 1],
                '  Fork:',
                memory[addr + 2]
            );
        end;
    end;



    begin

        repeat

            writeln('(w)ord-input  (i)nstruction-input  (o)utput  (s)tep  (q)uit');
            userCommand := readkey;

            if userCommand = 'w' then wordInput;

            if userCommand = 'i' then input;

            if userCommand = 'o' then output;

            if userCommand = 's' then step;

        until userCommand = 'q';
    end.


