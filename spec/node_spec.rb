require 'spec_helper'

describe 'API' do

  context 'Node' do

    it 'Flows' do
      get "/Flows",
        { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq 200
    end

    it 'List' do
      get "/GetNodeList",
        { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq 200
    end

  end

end

