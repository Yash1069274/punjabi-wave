import random

# Complete, auto-generated database of diverse Punjabi genres
punjabi_tracks = [
    {"id": 1, "title": "Bhangra Beats Vol 1", "tempo": "Fast", "type": "Traditional"},
    {"id": 2, "title": "Majha Hip Hop", "tempo": "Fast", "type": "Modern"},
    {"id": 3, "title": "Sufi Spirit", "tempo": "Slow", "type": "Folk"},
    {"id": 4, "title": "Doaba Dhol Mix", "tempo": "Fast", "type": "Traditional"},
    {"id": 5, "title": "Pind Acoustic", "tempo": "Slow", "type": "Melody"},
]

def ai_punjabi_recommender(user_history):
    """
    Analyzes what user listened to and serves the next Punjabi track for free.
    """
    if not user_history:
        return random.choice(punjabi_tracks)
    
    # Simple AI logic matching preferred tempo
    last_played = user_history[-1]
    preferred_tempo = last_played['tempo']
    
    recommendations = [t for t in punjabi_tracks if t['tempo'] == preferred_tempo and t['id'] != last_played['id']]
    
    return random.choice(recommendations) if recommendations else random.choice(punjabi_tracks)

# Example Execution
user_history = [{"id": 1, "title": "Bhangra Beats Vol 1", "tempo": "Fast", "type": "Traditional"}]
print("AI Next Track Recommendation:", ai_punjabi_recommender(user_history))
