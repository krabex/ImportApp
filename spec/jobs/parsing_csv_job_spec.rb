require 'rails_helper'

RSpec.describe ParsingCsvJob do

  before :each do
    @file = ParsingFile.create! 
    @job = ParsingCsvJob.new(@file.id)
  end

  describe "parse_date" do
    it "should parse string with date in format %m/%d/%Y" do
      expect(@job.send(:parse_date, "10/29/2000")).to eq(DateTime.new(2000,10,29))
    end

    it "should parse string with date in format %d-%m-%Y" do
      expect(@job.send(:parse_date, "29-10-2000")).to eq(DateTime.new(2000,10,29))
    end

    it "should parse string with date in format %Y-%m-%d" do
      expect(@job.send(:parse_date, "2000-10-29")).to eq(DateTime.new(2000,10,29))
    end
  end

  describe "add_categories" do
    before do
      Category.create(name: "C1")
    end
    
    subject { @job.send(:add_categories, Operation.new, ["C1", "C2"]) }

    it "should add categories without repetitions" do
      expect { subject }.to change { Category.count  }.from(1).to(2)
    end
  end

  describe "parse_row" do
    before :each do
      Company.create!(name: "company")
      headers = ["company", "invoice_num", "invoice_date", "operation_date", 
                 "amount", "reporter", "notes", "status", "kind"]
      values = ["company", "1234", "10-09-2010", "20-01-2001", "2", "Smith", "", "accepted", "C1;C2"]
      @row = headers.zip(values).to_h 
    end
    
    subject { @job.send(:parse_row, @row) }

    it "should add new operation" do
      expect { subject }.to change { Operation.count }.by(1)
    end

    it "should add new categories" do
      expect { subject }.to change { Category.count }.by(2)
    end

  end

  describe "parse file" do
    before :each do
      Company.create(name: "company")
    end

    let(:file_content) { 
       "company,invoice_num,invoice_date,operation_date,amount,reporter,notes,status,kind\n
        company,1111,10-09-2010,20-01-2001,2,Smith,"",accepted,C1;C2\n
        company,1111,10-09-2010,20-01-2001,2,Smith,"",not_accepted,C2;C3\n
        company,2222,10-09-2010,20-01-2001,2,Smith,"",accepted,C2;C3\n
        invalid,5555,10-09-2010,20-01-2001,2,Smith,"",not_accepted,C2;C4\n" 
    }
    let(:file_stub) { StringIO.new(file_content) }
    subject { @job.send(:parse_file, file_stub) }

    it "should add new operations" do
      expect { subject }.to change { Operation.count }.by(2)
    end

    it "should add new categories" do
      expect { subject }.to change { Category.count }.by(3)
    end

  end

end
