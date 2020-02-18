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

## Functionality

### Data Exports

#### Process

Transcription data files are generated and saved to storage when a transcription is approved, and removed from storage when a transcription is unapproved.

When a transcription is approved, four files are generated for the transcription:
- raw_data.json: raw unparsed transcription data as json
- consensus_text.txt: transcription text only
- transcription_metadata.csv: datatable with metadata about the transcription
- transcription_line_metadata.csv: datatable with metadata about each line of the transcription
 
Users with edit permissions have the ability to download transcription data for a single transcription, or for a project, workflow, or transcription group. Files will be downloaded directly to the browser as a single zip file with a directory structure that mirrors the way that the transcriptions are grouped in the app (e.g. project_a/workflow_b/group_c/transcription_4/files).

<details>
<summary><strong>Talking with Azure Blob Storage</strong></summary>
<p>
  
Connecting to Blob Storage in Tove is handled by [Rails Active Storage](https://guides.rubyonrails.org/active_storage_overview.html). Calls to upload transcription data to storage, or remove it from storage occur within the Transcription Controller.

</p>
<p>
  
Note that as of today (Feb 17, 2019), setup instructions for the current stable version of Rails (6.0.1) differ from the setup instructions for Rails Edge – be careful to look at the correct docs.

</p>
  
</details>

<details>
  
<summary><strong>DataExports::DataStorage - Using Temp Directories</strong></summary>
 <p>

The process for downloading files from storage, zipping, and sending the zip file to the client makes use of [ruby temp directories](https://ruby-doc.org/stdlib-2.5.1/libdoc/tmpdir/rdoc/Dir.html). All files generated during this process are downloaded to the temp directory. When the block opened by the `Dir.mktmpdir` function closes, the temp directory is removed automatically, and the generated files are removed along with it.
    
</p>
<p>
  
Hence, the step of sending the zip file to the client must happen within a yield block – see `TranscriptionController#export` for example. This allows the process of sending the file to happen within the block opened by the `Dir.mktmpdir` function.

</p>
  
</details>

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
