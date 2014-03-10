require 'spec_helper'

describe "Capturing output" do

  describe "STDOUT" do
    it "doesn't actually output to STDOUT" do
      string = capture_stdout do
        capture_stdout { puts "Hello world!" }
      end
      expect(string).to be_empty
    end

    it "returns a string" do
      string = capture_stdout { puts "Hello world!" }
      expect(string).to eql("Hello world!\n")
    end
  end


  describe "STDERR" do
    it "doesn't actually output to STDERR" do
      string = capture_stderr do
        capture_stderr { $stderr.puts "Hello world!" }
      end
      expect(string).to be_empty
    end

    it "returns a string" do
      string = capture_stderr { $stderr.puts "Hello world!" }
      expect(string).to eql("Hello world!\n")
    end
  end

end
