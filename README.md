# bashcards
Practice flashcards in bash.

Run `./bashcards` to practice your flashcards.

```
λ ./bashcards
What would you like to practice?
1. Spanish
2. Swedish
3. German
> 1
Spanish

–––––––––––––––
|             |
|  Te quiero  |
|             |
–––––––––––––––
(Press return to flip)

––––––––––––––––
|              |
|  I love you  |
|              |
––––––––––––––––
(Press return for next card)
```

## Adding a Bashcard Group
To add some Swedish bashcards, all you need to do is add a `"Swedish"` key to
the `groups` array:

```bash
declare -a groups=(
  "Spanish"
  "Swedish"
  "German"
)
```

Then you define an associative array of the same name:

```bash
declare -A Swedish=(
  ["Goodbye"]="Adjö"
  ["Hello"]="Hallå"
  ["I love you"]="Jag älskar dig"
  ["We are very happy"]="Vi är väldigt lyckliga"
)
```

That's it!
