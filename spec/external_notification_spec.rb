require 'spec_helper'
require_relative '../lib/external_notification'

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
          to raise_error( ConstantStore::UnprocessableEndpoints )
        end
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
    let( :receiver  ) { double }
    let( :endpoints ) { double }
    subject { ExternalNotification.new }

    it 'returns the response to the call' do
      subject.should_receive( :urlize ).with( receiver ) { "url" }
      subject.should_receive( :request_to ).with( "url" ) { "response" }
      subject.should_receive( :handle_response ).with( "response" )
      subject.send_to( receiver )
    end
  end

  describe 'Private methods' do
    describe '#handle_response private method' do
      pending 'yet to be implemented'
    end

    describe '#urlize private method' do
      subject { ExternalNotification.new }

      context 'when a key is inputted' do
        let( :receiver  ) { :test_endpoint }
        let( :endpoints ) { { :test_endpoint => 'http://test.url' } }
        before do
          stub_const 'ExternalNotification::KNOWN_ENDPOINTS', endpoints
        end

        it 'parses the URI found in the KNOWN_ENDPOINTS value for the input key' do
          URI.should_receive( :parse ).with 'http://test.url'
          subject.send :urlize, receiver
        end
      end

      context 'when a string is inputted' do
        let( :receiver ) { 'http://test_2.url' }
        it 'parses the URI from the string' do
          URI.should_receive( :parse ).with 'http://test_2.url'
          subject.send :urlize, receiver
        end
      end

      it 'adds the @content to url if present' do
        subject.instance_variable_set( '@content', 'a=23' )

        URI.should_receive( :parse ).with 'http://test_2.url?a=23'
        subject.send :urlize, 'http://test_2.url'
      end
    end

    describe '#request_object_for private method' do
      subject { ExternalNotification.new }
      let( :path ) { 'http://test.path' }
      
      context 'when @request type is :GET' do
        before { subject.instance_variable_set '@request_type', :GET }
        it 'returns an appropiate Net::HTTP::Get request object' do
          subject.send( :request_object_for, path ).class.
          should eq Net::HTTP::Get
        end
      end
      context 'when @request type is :POST' do
        before { subject.instance_variable_set '@request_type', :POST }
        it 'returns an appropiate Net::HTTP::Post request object' do
          subject.send( :request_object_for, path ).class.
          should eq Net::HTTP::Post
        end
      end
      context 'when @request type is nil' do
        before { subject.instance_variable_set '@request_type', nil }
        it 'returns an appropiate Net::HTTP::Get request object' do
          subject.send( :request_object_for, path ).class.
          should eq Net::HTTP::Get
        end
      end
    end

    describe '#request_to private method' do
      let( :url_object ) do
        double :host => 'endpoint.test',
               :port => '3000',
               :to_s => 'http://endpoint.test'
      end
      before do
        stub_request( :get, 'http://endpoint.test:3000/' ).to_return( :status => 200 )
        stub_request( :post, 'http://endpoint.test:3000/' ).to_return( :status => 201 )
      end

      context 'when a get request' do
        before { subject.instance_variable_set '@request_type', :GET }

        it 'sends the request to the given endpoint' do
          subject.send( :request_to, url_object ).code.should eq "200" 
        end
      end

      context 'when a post request' do
        before { subject.instance_variable_set '@request_type', :POST }

        it 'sends the request to the given endpoint' do
          subject.send( :request_to, url_object ).code.should eq "201" 
        end
      end
    end
  end
end