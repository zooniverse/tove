require 'zip'

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = File.expand_path(input_dir)
    @output_file = File.expand_path(output_file)
  end

  def write
    # remove entries referencing curr folder and parent folder
    entries = Dir.entries(@input_dir) - %w[. ..]

    Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      # relative path of file being added to the zip
      relative_path = path == '' ? e : File.join(path, e)
      # full path
      full_path = File.join(@input_dir, relative_path)

      if File.directory? full_path
        recursively_zip_directory(full_path, zipfile, relative_path)
      else
        put_into_archive(full_path, zipfile, relative_path)
      end
    end
  end

  def recursively_zip_directory(full_path, zipfile, relative_path)
    zipfile.mkdir relative_path
    subdir = Dir.entries(full_path) - %w[. ..]
    write_entries subdir, relative_path, zipfile
  end

  def put_into_archive(full_path, zipfile, relative_path)
    zipfile.add(relative_path, full_path)
  end
end