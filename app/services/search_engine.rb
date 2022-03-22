class SearchEngine
  def initialize(service_name, geolocation)
    @service_name = service_name
    @geolocation  = geolocation
  end

  def call
    find_locations(read_file)
  end

  def read_file
    JSON.parse(File.read(Rails.root.join('data.json')))
  end

  def find_locations(locations)
    return if locations.blank?

    matched_locations = { 'results' => [] }
    locations.each do |location|
      if (score = String::Similarity.cosine(location['name'], @service_name).to_f) > 0.7
        matched_locations['results'] << location.merge('distance' => calculate_distance(location), 'score' => score * 100)
      end
    end
    matched_locations.merge!('totalHits' => matched_locations['results'].size, 'totalDocuments' => locations.size)
    matched_locations
  end

  def calculate_distance(location)
    location_coordinates = [location.dig('position', 'lat'), location.dig('position', 'lng')]
    return -1 if location_coordinates.include?(nil)

    given_loc_coordinates = Geocoder.search(@geolocation)&.first&.coordinates
    return -1 if given_loc_coordinates.blank?

    distance = Geocoder::Calculations.distance_between(given_loc_coordinates, location_coordinates, units: :km).to_f
    distance > 0.0 ? "#{distance} KM" : distance
  end
end
