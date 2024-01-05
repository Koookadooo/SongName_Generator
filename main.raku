#Function to load all data, line-by-line (splitting on new line character - \n), from a text file #into our program

sub load_txt(Str $file) {
	my $data = $file.IO.open;
    	my @lines = $data.split: "\n", :close; 
    	return @lines
}

#creating an array of lines written from file using our above function.
my @data = load_txt("tracks.txt");


#-------------------------------------------------------------------------------------------------
#function using regular expressions to match everything before the title and return the post match, #or everything after the match i.e. the title

sub title_regex (Str $line) {
  if $line ~~ /.*(\<SEP\>)/ {
    my $new_line = $/.postmatch;
    return $new_line
  }
  else { 
    my $new_line =  $line;
    return $new_line
  }
}


#Function using regular expression to remove extraneous data after the song title. We match the #extraneous data and then use prematch to return everything before it. if/else to account for #possible lack of extraneous data.

sub superfluous_regex (Str $line) {
  if $line ~~ /(\")|(\))|(\()|([f\/])|([ft\.])|('-')|(\[)|(\])|(\{)|(\})|(\/)|(\\)|('_')|(\:)|(\`)|(\+)|(\=)|([feat\.])/ {
    my $new_line = $/.prematch;
    return $new_line;
  }
  else{
    my $new_line = $line;
    return $new_line;
  }
}


#function using regular expression to remove any non english characters other than '. We match all #character we want and return that line. if/else to account for titles that don't include our match

sub english_regex (Str $line) {
  if $line ~~ /<[a..zA..Z\s']>+/ {
    my $new_line = $/.Str;
    return $new_line;
  }
  else {
    my $new_line = " ";
    return $new_line
  }
}


#function to read our data line by line and use above functions to trim our data accordingly

sub save_title (@data) {
	my @song_titles;
	for @data -> $line {
		my $pre_title = title_regex($line);
    my $pre_title2 = superfluous_regex($pre_title);
    my $song_title = english_regex($pre_title2);
		@song_titles.push($song_title);
	}
	return @song_titles
}


#making an array and setting it to our save_title function to fill it with trimmed song titles

my @song_titles = save_title(@data);


#----------------------------------------------------------------------------------------------
#Function to take our data and turn it into bigrams w/ frequency of occurence, or nested a hash #table using one word following another and the frequency it happens. We do this line by line and at #the end of the line our bigram will be the last word followed by $ and the frequency of the #occurence

sub create_bigrams (@song_titles) {
  my %hash_words;
  for @song_titles -> $song_title {
    my @title_words = $song_title.words.split(' ', :skip-empty);
    loop (my $i = 0; $i < @title_words.elems; $i++) {
      if ($i == @title_words.elems - 1) {
        my $word1 = @title_words[$i];
        my $word2 = '$';
        %hash_words{$word1}{$word2}++;
      }
      else {
        my $word1 = @title_words[$i];
        my $word2 = @title_words[$i+1];
        %hash_words{$word1}{$word2}++;
      }
    }
  }
  return %hash_words
}

#making a nested has_table using our function above
my %hash_words = create_bigrams(@song_titles);


#---------------------------------------------------------------------------------------------------
#function to to return a randomly chosen word from the ten most frequent words following the word #passed to the function. We do this referencing our nested hash table and the frequency vals.
#We need to check that there is a word following given word in hashtable
#We need to count the number of possible word choices and account for less than 10 choices
#We make a loop which iterates the lesser of total possible choices and 10
#We pull the max freq choice, insert if into an array, then delete it from hash table each iterartion
#make a rand number either 0-9 or 0-$num_choices and use that to return the index position in array

sub next_word ($word){
  if %hash_words{$word}:exists {    
    my @freq_words; 
    my $num_choices = %hash_words{$word}.elems-1; 
    my $iter_count = $num_choices > 10 ?? 10 !! $num_choices; 
    loop (my $i = 0; $i < $iter_count; $i++) { 
      my $freq_max = 0;
      my $max_word;
      for %hash_words{$word}.kv -> $word2, $word2_freq { 
        if ($word2_freq > $freq_max) {
          $max_word = $word2; 
	        $freq_max = $word2_freq;
        }
      }
      @freq_words.push($max_word);
	    %hash_words{$word}{$max_word}:delete;
    }
    if @freq_words.elems <10 {
      my $rand_idx = Int(%hash_words{$word}.elems-1.rand);
      return @freq_words[$rand_idx];
    }
    else {
      my $rand_idx = Int(9.rand);
      return @freq_words[$rand_idx];
    }
  }
  return "\$";
}


#----------------------------------------------------------------------------------------------------
#Function to return systematically call the above function a limited number of times and generate an #array of next words
#Each loop iteration the word which was return from the next_word call is fed back into next_word
#Iterations are dependent on $word_limit argument
#Iterations stop if we run into a null or '$'
#Iterations stop if we run into a word already entered into our array.
#we keep track of the above by inputing generated words into a hash table and check if the next word #is already there or not

sub dynamic_titles ($seed_word, $word_limit) {
  my @title.append: $seed_word;
  my %duplicate_hash;
  loop (my $i = 0; $i < $word_limit-1; $i++) {
    my $next_word = next_word(@title[$i]);
    if ($next_word ne "\$" and $next_word.defined) {
      %duplicate_hash{$next_word}++;

      if (%duplicate_hash{$next_word} > 1) {
        last;
      }
      else {
        @title.append: $next_word;
      }
    }
    else {
      last;
    }
  }
  return @title;
}


#---------------------------------------------------------------------------------------------------
#instantiating an array of seed words and a word limit value

my @seed_words = ["The", "Songs", "Are", "World", "Please", "Without", "Your", "Change", "Sea", "We"];
my $word_limit = 6;

#function to loop through each seed word in the above array and call dynamic titles function to #generate a titles for each seed word
#function take an array and a word limit as arguments and uses a loop to pass a word form array and #word limit to dynamic titles function.
#function then take those titles and writes them to a blank text file.

sub output_titles (@seed_words, $word_limit) {
	my $of = open "titles.txt", :w;
	for @seed_words -> $seed_word {
		$of.print(dynamic_titles($seed_word, $word_limit),"\n");
	}
	$of.close;
}

output_titles(@seed_words, $word_limit)