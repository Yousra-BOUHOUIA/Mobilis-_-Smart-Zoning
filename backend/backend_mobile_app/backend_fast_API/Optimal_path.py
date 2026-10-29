import json
import numpy as np
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp
import math
from typing import List, Dict, Tuple
import folium
from folium import plugins
import os

# Get the directory of the current file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def delete_existing_files():
    """Delete existing path.json and optimal_path_map.html files if they exist."""
    path_file = os.path.join(BASE_DIR, 'path.json')
    map_file = os.path.join(BASE_DIR, 'optimal_path_map.html')
    
    if os.path.exists(path_file):
        os.remove(path_file)
    if os.path.exists(map_file):
        os.remove(map_file)

def calculate_distance_matrix(locations: List[Dict[str, float]]) -> List[List[int]]:
    """Calculate the distance matrix between all locations."""
    size = len(locations)
    matrix = [[0] * size for _ in range(size)]
    
    for i in range(size):
        for j in range(size):
            if i != j:
                # Calculate Haversine distance between two points
                lat1, lon1 = locations[i]['latitude'], locations[i]['longitude']
                lat2, lon2 = locations[j]['latitude'], locations[j]['longitude']
                
                # Convert to radians
                lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
                
                # Haversine formula
                dlat = lat2 - lat1
                dlon = lon2 - lon1
                a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
                c = 2 * math.asin(math.sqrt(a))
                r = 6371  # Radius of earth in kilometers
                
                # Convert to meters and round to integer
                distance = int(c * r * 1000)
                matrix[i][j] = distance
    
    return matrix

def solve_tsp(distance_matrix: List[List[int]]) -> Tuple[List[int], int]:
    """Solve the TSP using Google OR-Tools."""
    manager = pywrapcp.RoutingIndexManager(len(distance_matrix), 1, 0)
    routing = pywrapcp.RoutingModel(manager)

    def distance_callback(from_index, to_index):
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return distance_matrix[from_node][to_node]

    transit_callback_index = routing.RegisterTransitCallback(distance_callback)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

    # Set search parameters
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)
    search_parameters.local_search_metaheuristic = (
        routing_enums_pb2.LocalSearchMetaheuristic.GUIDED_LOCAL_SEARCH)
    search_parameters.time_limit.FromSeconds(30)

    # Solve the problem
    solution = routing.SolveWithParameters(search_parameters)

    if solution:
        index = routing.Start(0)
        route = []
        while not routing.IsEnd(index):
            route.append(manager.IndexToNode(index))
            index = solution.Value(routing.NextVar(index))
        
        # Calculate total distance
        total_distance = 0
        for i in range(len(route) - 1):
            total_distance += distance_matrix[route[i]][route[i + 1]]
        
        return route, total_distance
    return [], 0

def create_map(optimal_path: List[Dict], total_distance: int) -> None:
    """Create an interactive map showing the optimal path."""
    # Create a map centered at the first PDV
    first_pdv = optimal_path[0]
    m = folium.Map(
        location=[first_pdv['latitude'], first_pdv['longitude']],
        zoom_start=10,
        tiles='OpenStreetMap'
    )

    # Add markers for each PDV
    for i, pdv in enumerate(optimal_path):
        # Create popup content
        popup_content = f"""
        <b>PDV: {pdv['key']}</b><br>
        Commune: {pdv['commune']}<br>
        Daira: {pdv['daira']}<br>
        Wilaya: {pdv['wilaya']}<br>
        Visit Order: {i + 1}
        """
        
        # Add marker
        folium.Marker(
            location=[pdv['latitude'], pdv['longitude']],
            popup=folium.Popup(popup_content, max_width=300),
            icon=folium.Icon(color='red' if i == 0 else 'blue', icon='info-sign')
        ).add_to(m)

    # Draw lines connecting the PDVs in order
    locations = [[pdv['latitude'], pdv['longitude']] for pdv in optimal_path]
    folium.PolyLine(
        locations,
        color='blue',
        weight=2.5,
        opacity=1,
        popup=f'Total Distance: {total_distance/1000:.2f} km'
    ).add_to(m)

    # Add a legend
    legend_html = f'''
    <div style="position: fixed; bottom: 50px; left: 50px; z-index: 1000; background-color: white; padding: 10px; border: 2px solid grey; border-radius: 5px;">
        <p><strong>Legend:</strong></p>
        <p><span style="color: red;">●</span> Start Point</p>
        <p><span style="color: blue;">●</span> PDV Points</p>
        <p><span style="color: blue;">━</span> Optimal Path</p>
        <p>Total Distance: {total_distance/1000:.2f} km</p>
    </div>
    '''
    m.get_root().html.add_child(folium.Element(legend_html))

    # Save the map
    m.save('optimal_path_map.html')

def main():
    try:
        # Delete existing files first
        delete_existing_files()
        
        # Read PDVs data with correct path
        pdvs_path = os.path.join(BASE_DIR, 'PDVs.json')
        with open(pdvs_path, 'r', encoding='utf-8') as f:
            pdvs_data = json.load(f)

        # Extract locations and keep all info
        locations = []
        pdv_keys = list(pdvs_data.keys())
        for key in pdv_keys:
            pdv = pdvs_data[key]
            coords = pdv.get('coordinates', {})
            locations.append({
                'key': key,
                'commune': pdv.get('commune', ''),
                'daira': pdv.get('daira', ''),
                'wilaya': pdv.get('wilaya', ''),
                'latitude': float(coords.get('latitude', 0)),
                'longitude': float(coords.get('longitude', 0))
            })

        # Calculate distance matrix
        distance_matrix = calculate_distance_matrix(locations)

        # Solve TSP
        optimal_route, total_distance = solve_tsp(distance_matrix)

        # Prepare output data
        output_data = {
            'optimal_path': [],
            'total_distance_meters': total_distance
        }

        # Add PDVs in optimal order
        for idx in optimal_route:
            pdv_info = locations[idx]
            output_data['optimal_path'].append({
                'key': pdv_info['key'],
                'commune': pdv_info['commune'],
                'daira': pdv_info['daira'],
                'wilaya': pdv_info['wilaya'],
                'latitude': pdv_info['latitude'],
                'longitude': pdv_info['longitude'],
                'visit_order': len(output_data['optimal_path']) + 1,
                'status': False  # Added status field, default to False
            })

        # Save to path.json with correct path
        path_file = os.path.join(BASE_DIR, 'path.json')
        with open(path_file, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=4, ensure_ascii=False)

        # Create and save the map with correct path
        map_file = os.path.join(BASE_DIR, 'optimal_path_map.html')
        create_map(output_data['optimal_path'], total_distance)
        os.rename('optimal_path_map.html', map_file)

        print(f"Optimal path has been calculated and saved to path.json")
        print(f"Interactive map has been saved to optimal_path_map.html")
        print(f"Total distance: {total_distance/1000:.2f} kilometers")
        print(f"Number of PDVs in path: {len(optimal_route)}")

    except FileNotFoundError:
        print("Error: PDVs.json file not found")
    except json.JSONDecodeError:
        print("Error: Invalid JSON format in PDVs.json")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    main()
