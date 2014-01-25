require 'spec_helper'
require_relative '../external_notification'

describe ExternalNotification do
  before { ExternalNotification.const_set 'KNOWN_ENDPOINTS', {} }

  describe 'Initialization' do
    context 'when no enpoints option provided' do
      subject { ExternalNotification.new }
      
      it 'creates a ExternalNotification instance' do
        subject.class.should eq ExternalNotification
      end
      it 'assigns a get request_type by default' do
        subject.instance_variable_get( '@request_type' ).should eq :GET
      end
      it 'does not set any KNOWN_ENDPONITS' do
        subject.class.const_get( 'KNOWN_ENDPOINTS' ).should eq Hash.new
      end
    end

    context 'when endpoints input provided' do
      context 'when endpoints input is a hash' do
        let( :endpoints ) do
          { :endpont_1 => "endpoint", :endpont_2 => "endpoint" }
        end
        subject { ExternalNotification.new endpoints }

        it 'creates a ExternalNotification instance' do
          subject.class.should eq ExternalNotification
        end
        it 'assigns a get request_type by default' do
          subject.instance_variable_get( '@request_type' ).should eq :GET
        end
        it 'sets the KNOWN_ENDPONITS with the provided endpoints' do
          subject.class.const_get( 'KNOWN_ENDPOINTS' ).should eq endpoints
        end
      end

      context 'when endpoints input is not a hash' do
        let( :endpoints ) { "enpoints as string" }

        it 'raises a UnprocessableEndpoints error' do
          expect{ ExternalNotification.new endpoints }.
          to raise_error( ExternalNotification::UnprocessableEndpoints )
        end
      end
    end
  end

  describe '#import_endpoints' do
    context 'when a hash input' do
      let( :endpoints ) do
        { :endpont_1 => "endpoint", :endpont_2 => "endpoint" }
      end
      subject { ExternalNotification.new }
      before  { subject.import_endpoints( endpoints ) }

      it 'sets the KNOWN_ENDPONITS with the provided endpoints' do
        subject.class.const_get( 'KNOWN_ENDPOINTS' ).should eq endpoints
      end
    end

    context 'when input is not a hash' do
      let( :endpoints ) { "enpoints as string" }

      it 'raises a UnprocessableEndpoints error' do
        expect{ ExternalNotification.new endpoints }.
        to raise_error( ExternalNotification::UnprocessableEndpoints )
      end
    end
  end

  describe '#with' do
    context 'when options get request_type provided' do
      let( :options ) do
        { 
          :request_type => :GET,
          :params       => { :param_1 => "aa", :param_2 => 1 }
        }
      end
      subject { ExternalNotification.new }
      before do
        options[:params].stub( :to_param ) { "param_1=aa&param_2=1" }
        subject.with( options )
      end

      it 'sets a post request type' do
        subject.instance_variable_get( '@request_type' ).should eq :GET
      end

      it 'sets the content with the given params options to param' do
        subject.instance_variable_get( '@content' ).
        should eq options[:params].to_param
      end
    end

    context 'when only params via options provided' do
      let( :options ) do
        { :params => { :param_1 => "aa", :param_2 => 1 } }
      end
      subject { ExternalNotification.new }
      before do
        options[:params].stub( :to_param ) { "param_1=aa&param_2=1" }
        subject.with( options )
      end

      it 'sets a post request type' do
        subject.instance_variable_get( '@request_type' ).should eq :POST
      end

      it 'sets the content with the given options to param' do
        subject.instance_variable_get( '@content' ).
        should eq options[:params].to_param
      end
    end

    context 'when only block provided' do
      let( :hash ) do
        { :param_1 => "aa", :param_2 => 1 }
      end
      subject { ExternalNotification.new }
      before do
        hash.stub( :to_param ) { "param_1=aa&param_2=1" }
        subject.with{ hash }
      end

      it 'sets a post request type' do
        subject.instance_variable_get( '@request_type' ).should eq :POST
      end

      it 'sets the content with the given block result to param' do
        subject.instance_variable_get( '@content' ).
        should eq hash.to_param
      end
    end

    context 'when both params via options and block provided' do
      let( :options ) do
        { :params => { :param_1 => "aa", :param_2 => 1 } }
      end
      let( :hash ) do
        { :param_1 => "aa", :param_2 => 1 }
      end
      subject { ExternalNotification.new }
      before do
        hash.stub( :to_param ) { "param_1=aa&param_2=1" }
        subject.with( options ) { hash }
      end

      it 'sets a post request type' do
        subject.instance_variable_get( '@request_type' ).should eq :POST
      end

      it 'sets the content with the given block result to param' do
        subject.instance_variable_get( '@content' ).
        should eq hash.to_param
      end
    end
  end

  describe '#send_to' do
    context "when receiver is a key" do
      let( :receiver  ) { :test_endpoint }
      let( :endpoints ) do
        { :test_endpoint => "http://test_url.com" }
      end
      subject { ExternalNotification.new }
      before  { stub_const "ExternalNotification::KNOWN_ENDPOINTS", endpoints }
    
      
    end
    context "when receiver is a valid url string" do
      let( :receiver ) { "http://test_url.com" }
    end
  end
end