require 'spec_helper'
require 'json'
require File.join(File.dirname(__FILE__), '../../', 'mobage_core.rb')

describe Locations do
  let(:err) {Proc.new {fail 'API request failed'}}

  before(:each) do
    @api_missing_error = {'success' => 'false', 'error' => 'API not found. Try /version, /status, or a documented api call'}
  end


  context 'when getting a user' do
    it 'by id' do
      with_api(RackRoutes) do |api|
        get_request({:path => '/users/1'}, err) do |cb|
          cb.response_header.status.should == 200
          if api.config['use_sql_direct'] == true
            cb.response.should == '{"id":1,"gamertag":"quentin","email":"quentin@example.com","phone_number":null,"url":"http://www.quentin.com/","motto":null,"description":"fun guy","badge_id":1,"crypted_password":"00742970dc9e6319f8019fd54864d3ea740f04b1","salt":"7e3041ebc2fc05a40c60028e2c4901a81035d3cd","created_at":"2011-08-19T17:52:23-07:00","updated_at":"2011-08-24T17:52:24-07:00","activation_code":"8f24789ae988411ccf33ab0c30fe9106fab32e9b","activated_at":"2011-08-19T17:52:23-07:00","state":"active","deleted_at":null,"flags_count":1,"buddies_count":0,"tweet":"is awesome","tweeted_at":"2011-08-19T17:52:23-07:00","email_hash":"3e34e0a37431ee72319c61f92b1304d636101419","reset_code":null,"photo_file_name":"rolando.png","photo_content_type":"image/jpg","photo_file_size":5229,"photo_updated_at":null,"first_name":null,"last_name":null,"fullname_privacy":0,"gamerscore":2000,"age_group":null,"age_restricted":0,"opt_in":0,"device_token":"891564dff68bb18b1a5c3b05e950adb99a80067a4d29f99f82d51130dd453ce8","social_photo_url":null}'
          else
            cb.response.should == '{"id":1,"gamertag":"quentin","state":"active","badge_icon_url":null,"friends":[4]}'
          end
        end
      end

    end
  end


end
