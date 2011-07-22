require "spec_helper"

describe Xapit::Client::RemoteDatabase do
  before(:each) do
    @database = Xapit::Client::RemoteDatabase.new("http://localhost:1234")
  end

  %w[query add_document spelling_suggestion].each do |command|
    it "passes #{command} to remote server using Net::HTTP" do
      Net::HTTP.should_receive(:post_form).with(URI.parse("http://localhost:1234/xapit/#{command}"), {:send => "request"}.to_json).and_return({"receive" => "response"}.to_json)
      @database.send(command, :send => "request").should eq(:receive => "response")
    end
  end
end
