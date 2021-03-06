require_relative '../test_helper'
require 'gds_api/test_helpers/worldwide'

class WorldwideOrganisationTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Worldwide

  context "finding organisations in a location" do
    should "return organisations for the location" do
      results = load_fixture('australia')
      assert results[0].is_a?(WorldwideOrganisation)
      assert_equal ["UK Trade & Investment Australia", "British High Commission Canberra"], results.map(&:title)
    end
  end

  context "fco_sponsored?" do
    setup do
      @orgs = load_fixture('australia')
    end

    should "return true for an organisation sponsored by the FCO" do
      assert_equal true, @orgs[1].fco_sponsored?
    end

    should "return false otherwise" do
      assert_equal false, @orgs[0].fco_sponsored?
    end
  end

  context "offices with services" do
    should "find offices with service" do
      organisation = load_fixture('argentina').first
      matches = organisation.offices_with_service('Births and Deaths registration service')
      assert_equal 2, matches.length, "Wrong number of offices matched"
      assert_equal 'British Embassy Buenos Aires', matches[0].title
      assert_equal 'Consular', matches[1].title
    end

    should "fallback to main office" do
      organisation = load_fixture('andorra').first
      matches = organisation.offices_with_service('Obscure service')
      assert_equal 1, matches.length, "Wrong number of offices matched"
      assert_equal 'British Embassy', matches[0].title
    end

    should "return empty array if no offices" do
      organisation = load_fixture('brazil')[2]
      matches = organisation.offices_with_service('desired service')
      assert_equal [], matches
    end
  end

  context "attribute accessors" do
    setup do
      @organisation = load_fixture('australia')[1]
    end

    should "allow accessing required top-level attributes" do
      assert_equal "British High Commission Canberra", @organisation.title
    end

    context "accessing office details" do
      should "allow accessing office details" do
        assert_equal "British High Commission Canberra", @organisation.offices.main.title
      end

      should "have shortcut accessor for main office" do
        assert_equal "British High Commission Canberra", @organisation.main_office.title
      end

      should "have shortcut accessor for other offices" do
        assert_equal "British Consulate-General Sydney", @organisation.other_offices.first.title
      end

      should "have an accessor for all offices" do
        assert_equal 5, @organisation.all_offices.size
        assert_equal ["British High Commission Canberra", "British Consulate-General Sydney"], @organisation.all_offices.map(&:title)[0..1]
      end

      should "have an accessor for the URL" do
        assert_equal "https://www.gov.uk/government/world/organisations/british-high-commission-canberra", @organisation.web_url
      end
    end
  end

  def load_fixture(country)
    json = read_fixture_file("worldwide/#{country}_organisations.json")
    worldwide_api_has_organisations_for_location(country, json)
    WorldwideOrganisation.for_location(country)
  end
end
