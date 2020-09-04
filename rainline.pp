


Program Rainline;
uses    Crt;



type
    memType = array [Word] of Word;



var
    memory:         memType;
    userCommand:    Char;
    threadIterator: Word;



procedure createThread( instructionCounter: Word );
var
    location: Word;
begin

    { find an empty location for the new thread's Instruction Counter }
    location := 0;

    { while there's a thread here }
    while ( memory[location] > 0 )

    { and this thread's not marked as terminated }
    and ( memory[location] <> location )

    { keep searching }
    do location += 1;
    
    { then create new thread here }
    memory[location] := instructionCounter;
end;



procedure stepThread;
var
    instructionCounter: Word;
    source:             Word;
    destination:        Word;
    fork:               Word;
begin

    instructionCounter := memory[threadIterator];

    source :=       memory[instructionCounter];
    destination :=  memory[instructionCounter + 1];
    fork :=         memory[instructionCounter + 2];

    if source <> destination then
    begin

        { copy content of address A to address B }
        memory[destination] := memory[source];

        { let parent jump to the next instruction }
        memory[threadIterator] += 3;

    end else
    
        { else mark this thread as terminated }
        memory[threadIterator] := threadIterator;

    { then, fork if the fork address isn't the next instruction }
    if fork <> instructionCounter + 3 then createThread( fork );
end;



procedure step;
begin

    threadIterator := 0;
    
    while memory[threadIterator] > 0 do
    begin

        { if this thread is not marked as terminated }
        if memory[threadIterator] <> threadIterator then stepThread;

        threadIterator += 1;
    end;
end;



procedure printInstruction( address: Word );
begin
    writeln(
        '  [',
        address,
        ']  Source:',
        memory[address],
        '  Destination:',
        memory[address + 1],
        '  Fork:',
        memory[address + 2]
    );
end;



procedure wordInput;
var
    address:    Word;
    content:    Word;
begin

    write('Enter: Address Content (space-separated) > ');
    readln( address, content );

    memory[address] := content;
end;



procedure input;
var
    address:        Word;
    source:         Word;
    destination:    Word;
    fork:           Word;
begin

    write('Address ');
    readln( address );

    if address mod 3 <> 0 then

        writeln('Error: Wrong alignment')

    else begin

        write('Enter: Source Destination Fork (space-separated) > ');
        readln( source, destination, fork );

        memory[address] :=      source;
        memory[address + 1] :=  destination;
        memory[address + 2] :=  fork;

        printInstruction( address );
    end;
end;



procedure dump;
var
    start:  Word;
    length: Word;
    i:      Word;
begin

    write('Enter: Start > ');
    readln( start );

    write('Enter: Length > ');
    readln( length );

    for i := start to start + length do
    
        write('[', i, ']', memory[i], '  ');

    writeln;
end;



procedure output;
var
    start:  Word;
    length: Word;
    i:      Word;
begin

    write('Enter: Start > ');
    readln( start );

    write('Enter: Length > ');
    readln( length );

    if start mod 3 <> 0 then

        writeln('Error: Wrong alignment')

    else for i := 0 to length - 1 do
    
        printInstruction( start + i * 3 );
end;



begin

    repeat

        writeln('(w)ord-input  (i)nstruction-input  (d)ump-words  (o)utput-instructions  (s)tep  (q)uit');
        userCommand := readkey;

        if userCommand = 'w' then wordInput;

        if userCommand = 'i' then input;

        if userCommand = 'd' then dump;

        if userCommand = 'o' then output;

        if userCommand = 's' then step;

    until userCommand = 'q';
end.


