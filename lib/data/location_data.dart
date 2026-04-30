import '../models/city_location.dart';

const Map<String, String> usStates = {
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'FL': 'Florida',
  'GA': 'Georgia',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'MT': 'Montana',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
};

const List<CityLocation> cityLocations = [
  CityLocation(
      name: 'Birmingham',
      stateCode: 'AL',
      latitude: 33.5186,
      longitude: -86.8104),
  CityLocation(
      name: 'Anchorage',
      stateCode: 'AK',
      latitude: 61.2176,
      longitude: -149.8997),
  CityLocation(
      name: 'Phoenix',
      stateCode: 'AZ',
      latitude: 33.4484,
      longitude: -112.0740),
  CityLocation(
      name: 'Tucson', stateCode: 'AZ', latitude: 32.2226, longitude: -110.9747),
  CityLocation(
      name: 'Little Rock',
      stateCode: 'AR',
      latitude: 34.7465,
      longitude: -92.2896),
  CityLocation(
      name: 'Los Angeles',
      stateCode: 'CA',
      latitude: 34.0522,
      longitude: -118.2437),
  CityLocation(
      name: 'San Diego',
      stateCode: 'CA',
      latitude: 32.7157,
      longitude: -117.1611),
  CityLocation(
      name: 'San Francisco',
      stateCode: 'CA',
      latitude: 37.7749,
      longitude: -122.4194),
  CityLocation(
      name: 'San Jose',
      stateCode: 'CA',
      latitude: 37.3382,
      longitude: -121.8863),
  CityLocation(
      name: 'Sacramento',
      stateCode: 'CA',
      latitude: 38.5816,
      longitude: -121.4944),
  CityLocation(
      name: 'Denver', stateCode: 'CO', latitude: 39.7392, longitude: -104.9903),
  CityLocation(
      name: 'Colorado Springs',
      stateCode: 'CO',
      latitude: 38.8339,
      longitude: -104.8214),
  CityLocation(
      name: 'Hartford',
      stateCode: 'CT',
      latitude: 41.7658,
      longitude: -72.6734),
  CityLocation(
      name: 'Wilmington',
      stateCode: 'DE',
      latitude: 39.7391,
      longitude: -75.5398),
  CityLocation(
      name: 'Miami', stateCode: 'FL', latitude: 25.7617, longitude: -80.1918),
  CityLocation(
      name: 'Orlando', stateCode: 'FL', latitude: 28.5383, longitude: -81.3792),
  CityLocation(
      name: 'Tampa', stateCode: 'FL', latitude: 27.9506, longitude: -82.4572),
  CityLocation(
      name: 'Atlanta', stateCode: 'GA', latitude: 33.7490, longitude: -84.3880),
  CityLocation(
      name: 'Honolulu',
      stateCode: 'HI',
      latitude: 21.3099,
      longitude: -157.8581),
  CityLocation(
      name: 'Boise', stateCode: 'ID', latitude: 43.6150, longitude: -116.2023),
  CityLocation(
      name: 'Chicago', stateCode: 'IL', latitude: 41.8781, longitude: -87.6298),
  CityLocation(
      name: 'Indianapolis',
      stateCode: 'IN',
      latitude: 39.7684,
      longitude: -86.1581),
  CityLocation(
      name: 'Des Moines',
      stateCode: 'IA',
      latitude: 41.5868,
      longitude: -93.6250),
  CityLocation(
      name: 'Wichita', stateCode: 'KS', latitude: 37.6872, longitude: -97.3301),
  CityLocation(
      name: 'Louisville',
      stateCode: 'KY',
      latitude: 38.2527,
      longitude: -85.7585),
  CityLocation(
      name: 'New Orleans',
      stateCode: 'LA',
      latitude: 29.9511,
      longitude: -90.0715),
  CityLocation(
      name: 'Portland',
      stateCode: 'ME',
      latitude: 43.6591,
      longitude: -70.2568),
  CityLocation(
      name: 'Baltimore',
      stateCode: 'MD',
      latitude: 39.2904,
      longitude: -76.6122),
  CityLocation(
      name: 'Boston', stateCode: 'MA', latitude: 42.3601, longitude: -71.0589),
  CityLocation(
      name: 'Detroit', stateCode: 'MI', latitude: 42.3314, longitude: -83.0458),
  CityLocation(
      name: 'Minneapolis',
      stateCode: 'MN',
      latitude: 44.9778,
      longitude: -93.2650),
  CityLocation(
      name: 'Jackson', stateCode: 'MS', latitude: 32.2988, longitude: -90.1848),
  CityLocation(
      name: 'Kansas City',
      stateCode: 'MO',
      latitude: 39.0997,
      longitude: -94.5786),
  CityLocation(
      name: 'St. Louis',
      stateCode: 'MO',
      latitude: 38.6270,
      longitude: -90.1994),
  CityLocation(
      name: 'Billings',
      stateCode: 'MT',
      latitude: 45.7833,
      longitude: -108.5007),
  CityLocation(
      name: 'Omaha', stateCode: 'NE', latitude: 41.2565, longitude: -95.9345),
  CityLocation(
      name: 'Las Vegas',
      stateCode: 'NV',
      latitude: 36.1699,
      longitude: -115.1398),
  CityLocation(
      name: 'Manchester',
      stateCode: 'NH',
      latitude: 42.9956,
      longitude: -71.4548),
  CityLocation(
      name: 'Newark', stateCode: 'NJ', latitude: 40.7357, longitude: -74.1724),
  CityLocation(
      name: 'Albuquerque',
      stateCode: 'NM',
      latitude: 35.0844,
      longitude: -106.6504),
  CityLocation(
      name: 'New York',
      stateCode: 'NY',
      latitude: 40.7128,
      longitude: -74.0060),
  CityLocation(
      name: 'Buffalo', stateCode: 'NY', latitude: 42.8864, longitude: -78.8784),
  CityLocation(
      name: 'Charlotte',
      stateCode: 'NC',
      latitude: 35.2271,
      longitude: -80.8431),
  CityLocation(
      name: 'Raleigh', stateCode: 'NC', latitude: 35.7796, longitude: -78.6382),
  CityLocation(
      name: 'Fargo', stateCode: 'ND', latitude: 46.8772, longitude: -96.7898),
  CityLocation(
      name: 'Columbus',
      stateCode: 'OH',
      latitude: 39.9612,
      longitude: -82.9988),
  CityLocation(
      name: 'Cleveland',
      stateCode: 'OH',
      latitude: 41.4993,
      longitude: -81.6944),
  CityLocation(
      name: 'Oklahoma City',
      stateCode: 'OK',
      latitude: 35.4676,
      longitude: -97.5164),
  CityLocation(
      name: 'Portland',
      stateCode: 'OR',
      latitude: 45.5152,
      longitude: -122.6784),
  CityLocation(
      name: 'Philadelphia',
      stateCode: 'PA',
      latitude: 39.9526,
      longitude: -75.1652),
  CityLocation(
      name: 'Pittsburgh',
      stateCode: 'PA',
      latitude: 40.4406,
      longitude: -79.9959),
  CityLocation(
      name: 'Providence',
      stateCode: 'RI',
      latitude: 41.8240,
      longitude: -71.4128),
  CityLocation(
      name: 'Charleston',
      stateCode: 'SC',
      latitude: 32.7765,
      longitude: -79.9311),
  CityLocation(
      name: 'Sioux Falls',
      stateCode: 'SD',
      latitude: 43.5446,
      longitude: -96.7311),
  CityLocation(
      name: 'Nashville',
      stateCode: 'TN',
      latitude: 36.1627,
      longitude: -86.7816),
  CityLocation(
      name: 'Memphis', stateCode: 'TN', latitude: 35.1495, longitude: -90.0490),
  CityLocation(
      name: 'Houston', stateCode: 'TX', latitude: 29.7604, longitude: -95.3698),
  CityLocation(
      name: 'Austin', stateCode: 'TX', latitude: 30.2672, longitude: -97.7431),
  CityLocation(
      name: 'Dallas', stateCode: 'TX', latitude: 32.7767, longitude: -96.7970),
  CityLocation(
      name: 'San Antonio',
      stateCode: 'TX',
      latitude: 29.4241,
      longitude: -98.4936),
  CityLocation(
      name: 'Salt Lake City',
      stateCode: 'UT',
      latitude: 40.7608,
      longitude: -111.8910),
  CityLocation(
      name: 'Burlington',
      stateCode: 'VT',
      latitude: 44.4759,
      longitude: -73.2121),
  CityLocation(
      name: 'Virginia Beach',
      stateCode: 'VA',
      latitude: 36.8529,
      longitude: -75.9780),
  CityLocation(
      name: 'Richmond',
      stateCode: 'VA',
      latitude: 37.5407,
      longitude: -77.4360),
  CityLocation(
      name: 'Seattle',
      stateCode: 'WA',
      latitude: 47.6062,
      longitude: -122.3321),
  CityLocation(
      name: 'Spokane',
      stateCode: 'WA',
      latitude: 47.6588,
      longitude: -117.4260),
  CityLocation(
      name: 'Charleston',
      stateCode: 'WV',
      latitude: 38.3498,
      longitude: -81.6326),
  CityLocation(
      name: 'Milwaukee',
      stateCode: 'WI',
      latitude: 43.0389,
      longitude: -87.9065),
  CityLocation(
      name: 'Cheyenne',
      stateCode: 'WY',
      latitude: 41.1400,
      longitude: -104.8202),
];
