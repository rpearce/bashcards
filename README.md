# bashcards
Flashcards in Bash

Run `./bashcards` to practice your flashcards.

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
