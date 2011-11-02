require 'spec_helper'
require 'json'
require File.join(File.dirname(__FILE__), '../../', 'mobage_core.rb')

describe RackRoutes do
  let(:err) {Proc.new {fail 'API request failed: {#err}'}}

  before(:each) do
    @api_missing_error = {'success' => 'false', 'error' => 'API not found. Try /version, /status, or a documented api call'}
  end


  context 'when using maps' do
     it 'ignores #response' do
      expect {
        with_api(RackRoutes) do
          get_request({:path => '/'}, err) {}
        end
      }.to_not raise_error
    end

    it 'falls back to 404 Not Found on missing route' do
      with_api(RackRoutes) do
        get_request({:path => '/fooze'}, err) do |cb|
          cb.response_header.status.should == 404
          cb.response.should == @api_missing_error.to_json
        end
      end
      with_api(RackRoutes) do
        get_request({:path => '/'}, err) do |cb|
          cb.response_header.status.should == 404
          cb.response.should == @api_missing_error.to_json
        end
      end
    end

    it 'returns OK on /status' do
      with_api(RackRoutes) do
        get_request({:path =>'/status'}, err) do |cb|
          cb.response.should == 'OK'
        end
      end
    end

    it 'routes to the correct API' do
      with_api(RackRoutes) do
        get_request({:path => '/maptest'}, err) do |cb|
          cb.response_header.status.should == 200
          cb.response.should == {'success' => 'true', 'message' => 'GET maptest'}.to_json
        end
      end
    end

    it 'should handle request method properly' do
      with_api(RackRoutes) do
        post_request({:path => '/maptest'}, err) do |cb|
          cb.response_header.status.should == 200
          cb.response.should == {'success' => 'true', 'message' => 'POST maptest'}.to_json
        end
      end
    end

    it 'should reject improper request methods' do
      with_api(RackRoutes) do
        put_request({:path => '/maptest'}, err) do |cb|
          cb.response_header.status.should == 405
          cb.response_header['ALLOW'].split(/, /).should == %w(GET HEAD POST)
        end
      end
    end
  end

  context 'routes defined with get' do
    it 'should allow get' do
      with_api(RackRoutes) do
        get_request({:path => '/maptest'}, err) do |cb|
          cb.response_header.status.should == 200
          cb.response.should == {'success' => 'true', 'message' => 'GET maptest'}.to_json
        end
      end
    end
    it 'should allow head' do
      with_api(RackRoutes) do
        head_request({:path => '/maptest'}, err) do |cb|
          cb.response_header.status.should == 200
          cb.response.should == {'success' => 'true', 'message' => 'GET maptest'}.to_json
        end
      end
    end
  end

  context "defined in blocks" do
    it 'use middleware defined in the block' do
      with_api(RackRoutes) do
        get_request({:path => '/middleware_post_test'}, err) do |cb|
          cb.response_header.status.should == 405
          cb.response.should == {'error' => 'Invalid request method'}.to_json
          cb.response_header['ALLOW'].should == 'POST'
        end
      end
    end

    it 'again use middleware defined in the block' do
      with_api(RackRoutes) do
        post_request({:path => '/middleware_post_test'}, err) do |cb|
          cb.response_header.status.should == 200
          cb.response.should == {'success' => 'true', 'message' => 'POST middleware_post_test'}.to_json
        end
      end
    end
  end

  # pending

  context 'when instanciating database drivers'
    it 'should create the direct mysql connection pool'
    it 'should create the mongo connection pool'
    it 'should create the activerecord mysql connection pool'

end

