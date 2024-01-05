# Random Song Title Generator

Raku program which is given five seed words and then outputs 5 song names that are generated from those seed words and outputs them to a .txt file

The project first strips and cleans the song titles from a list of 100,000 song tracks and their metadata using REGEX. This list of songs is then processed into bigrams, or word pairs.
We make this into a nested hash table where we keep track of the bigrams and their frequency.
This is executed song title by song title, with the ending word being stored into a bigram with '$' following it along with the frequency of this occurence.

When we give this program seed words it looks at the nested hash table and randomly returns one of 5 most frequent words that follows the current or seed word.
It repeats this with the word it just returned until it finds a '$' or hits a song title word limit.

Once The program has written songs names for each of the seed words given, It ouputs them to a .txt file called file.txt.
