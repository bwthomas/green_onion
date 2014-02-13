require 'spec_helper'
require 'open3'

describe "bin/green_onion" do

  before(:all) do
    @tmp_path = './spec/tmp'
    @url = 'http://localhost:8070'
    @file1 = "#{@tmp_path}/root.png"
    @skinner_file = "#{@tmp_path}/skinner.rb"
  end

  describe "Skin Utility" do

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end     

    it "should run the skin task w/o any flags (need the --dir flag to keep spec directory clean)" do
      `bin/green_onion skin #{@url} -d=#{@tmp_path}`
      File.exist?(@file1).should be_true
    end

    it "should run the skin task w/ --method=p flag to run only percentage diff" do
      stdin, stdout, stderr = Open3.popen3("bin/green_onion skin #{@url} --dir=#{@tmp_path} --method=p --threshold=1 &&
                                            bin/green_onion skin #{@url} --dir=#{@tmp_path} --method=p --threshold=1")
      stderr.readlines.to_s.should include("above threshold set @")
    end

  end

  describe "Generator" do

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end     

    it "should build the skinner file" do
      `bin/green_onion generate --dir=#{@tmp_path}`
      File.exist?(@skinner_file).should be_true
    end

    it "should build the skinner file with the url included correctly" do
      `bin/green_onion generate --url=#{@url} --dir=#{@tmp_path}`
      skinner = IO.read(@skinner_file)
      skinner.should include("GreenOnion.skin_visual_and_percentage(\"http://localhost:8070\" + route)")
    end
    
  end
end
