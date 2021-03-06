


Program Rainline;
uses    Crt;



type
    memType = packed array [1..16777216] of Byte;



var
    memory:         memType;
    userCommand:    Char;
    threadIterator: Longword;



function getMem( address: Longword ) : Longword;
begin

    getMem :=   ( memory[address    ]        ) or
                ( memory[address + 1] shl 8  ) or
                ( memory[address + 2] shl 16 );
end;



procedure setMem( address, content : Longword );
begin

    memory[address    ] := content and $FF;
    memory[address + 1] := content and $FF00;
    memory[address + 2] := content and $FF0000;
end;



function isTerminated( thread: Longword ) : Boolean;
begin

    { a thread is considered terminated if its IP points to itself }
    isTerminated := getMem( thread ) = thread;
end;



procedure terminate( thread: Longword );
begin

    { we mark a thread as terminated by making its IP point to itself }
    setMem( thread, thread );
end;



procedure createThread( instructionPointer: Longword );
var
    location: Longword;
begin

    { find an empty location for the new thread's Instruction Pointer }
    { the IP zone starts at address 3 }
    location := 3;

    { while we're in the IP zone }
    while ( getMem( location ) > 0 )

    { and this is an active thread }
    and not isTerminated( location )

    { keep searching }
    do location += 3;
    
    { then create new thread here }
    setMem( location, instructionPointer );
end;



procedure stepThread;
var
    instructionPointer: Longword;
    source:             Longword;
    destination:        Longword;
    fork:               Longword;
begin

    instructionPointer := getMem( threadIterator );

    source :=       getMem( instructionPointer     );
    destination :=  getMem( instructionPointer + 3 );
    fork :=         getMem( instructionPointer + 6 );

    if source <> destination then
    begin

        { copy content of address A to address B }
        memory[destination] := memory[source];

        { let parent jump to the next instruction }
        setMem( threadIterator, instructionPointer + 9 );

    end else
    
        { else mark this thread as terminated }
        terminate( threadIterator );

    { then, fork if the fork address isn't the next instruction }
    if fork <> instructionPointer + 9 then createThread( fork );
end;



procedure step;
begin

    { the 1st thread's Instruction Pointer must be located at address 3 }
    { because the VM would freeze as soon as the 1st thread is terminated }
    threadIterator := 3;
    
    { while we're in the IP zone }
    while getMem( threadIterator ) > 0 do
    begin

        { if this thread is not marked as terminated }
        if not isTerminated( threadIterator ) then stepThread;

        threadIterator += 3;
    end;
end;



procedure printInstruction( address: Longword );
begin

    writeln(
        '  [',
        address,
        ']  Source:',
        getMem( address ),
        '  Destination:',
        getMem( address + 3 ),
        '  Fork:',
        getMem( address + 6 )
    );
end;



procedure wordInput;
var
    address:    Longword;
    content:    Longword;
begin

    write('Enter: Address Content (space-separated) > ');
    readln( address, content );

    setMem( address, content );
end;



procedure input;
var
    address:        Longword;
    source:         Longword;
    destination:    Longword;
    fork:           Longword;
begin

    write('Enter: Address (aligned) > ');
    readln( address );

    if address mod 9 <> 0 then

        writeln('Error: Wrong alignment')

    else begin

        write('Enter: Source Destination Fork (space-separated) > ');
        readln( source, destination, fork );

        setMem( address,        source );
        setMem( address + 3,    destination );
        setMem( address + 6,    fork );

        printInstruction( address );
    end;
end;



procedure dump;
var
    start:  Longword;
    length: Longword;
    i:      Longword;
begin

    write('Enter: Start > ');
    readln( start );

    write('Enter: Length > ');
    readln( length );

    i := start;
    while i < start + length do
    begin
        write('[', i, ']', memory[i], '-', memory[i + 1], '-', memory[i + 2], '  ');
        i += 3;
    end;

    writeln;
end;



procedure output;
var
    start:  Longword;
    length: Longword;
    i:      Longword;
begin

    write('Enter: Start (aligned) > ');
    readln( start );

    write('Enter: Length > ');
    readln( length );

    if start mod 9 <> 0 then

        writeln('Error: Wrong alignment')

    else for i := 0 to length - 1 do
    
        printInstruction( start + i * 9 );
end;



begin

    writeln('Rainline');

    repeat

        write('(w)ord-input  (i)nstruction-input  (d)ump-words  (o)utput-instructions  (s)tep  (q)uit  > ');

        userCommand := readkey;
        writeln(userCommand);

        if userCommand = 'w' then wordInput;

        if userCommand = 'i' then input;

        if userCommand = 'd' then dump;

        if userCommand = 'o' then output;

        if userCommand = 's' then step;

    until userCommand = 'q';
end.


