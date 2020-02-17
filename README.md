# TOVE: Transcription Object Viewer/Editor

Tove is the API for the [ALICE Text Editor](https://github.com/zooniverse/text-editor) tool. The text editor tool takes in reductions on transcription data from Caesar, and allows users to review, update and approve transcriptions.

## Setup

### Run app locally

1. Install dependencies:
- Rails 6.0.1
- Ruby 2.6.5
- PostgreSQL 9.5

2. Clone the repo `git clone https://github.com/zooniverse/tove.git` 

3. `cd` into the cloned folder   

4. Run `bundle install`  

5. Run `rails s` to start up the app locally


### Run app within a docker container

Prepare the Docker containers:

```
docker-compose build
docker-compose run --rm app bundle exec rails db:setup
docker-compose run --rm -e RAILS_ENV=test app bin/rails db:create
```

Run tests with:

```
docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec
```

Or interactively / manually in a docker shell

```
docker-compose run --rm -e RAILS_ENV=test app bash
# from the bash prompt
bin/rspec
```

## Namesake

>“You seem very clever at explaining words, Sir,” said Alice. “Would you kindly tell me the meaning of the poem ‘Jabberwocky’?”
>\
>\
>“Let’s hear it,” said Humpty Dumpty. “I can explain all the poems that ever were invented—and a good many that haven’t been invented just yet.”
>\
>\
This sounded very hopeful, so Alice repeated the first verse:
>\
>\
‘Twas brillig, and the slithy toves
Did gyre and gimble in the wabe:
All mimsy were the borogoves,
And the mome raths outgrabe.
>\
>\
“That’s enough to begin with,” Humpty Dumpty interrupted: “there are plenty of hard words there. ‘Brillig’ means four o'clock in the afternoon—the time when you begin broiling things for dinner.”
>\
>\
“That’ll do very well,” said Alice: “and ‘slithy’?”
>\
>\
“Well, ‘slithy’ means ‘lithe and slimy.’ ‘Lithe’ is the same as ‘active.’ You see it’s like a portmanteau—there are two meanings packed up into one word.”
>\
>\
“I see it now”, Alice remarked thoughtfully: “and what are ‘toves’?”
>\
>\
“Well, ‘toves’ are something like badgers—they’re something like lizards—and they’re something like corkscrews.”
>\
>\
“They must be very curious creatures.”
>\
>\
“They are that,” said Humpty Dumpty: “also they make their nests under sun-dials—also they live on cheese.”

--Lewis Carrol, "Through the Looking Glass"
