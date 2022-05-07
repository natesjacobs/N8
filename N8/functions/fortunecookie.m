function fortunecookie

fortune{1} = 'get back to work!'; 
fortune{2} = 'time for a break. Have you eaten yet?'; 
fortune{3} = 'it is probably too early to go home.'; 
fortune{4} = 'call your mom to say hi.';

rand = randi([1 length(fortune)],1);
disp(' ');
disp(['                 Nate says ... ' fortune{rand}]);
disp(' ');