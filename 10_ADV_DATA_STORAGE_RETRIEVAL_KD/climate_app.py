from flask import Flask, jsonify
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy import create_engine, func
import datetime as dt

app = Flask(__name__)

engine = create_engine("sqlite:///Resources/hawaii.sqlite")

# reflect an existing database into a new model
Base = automap_base()

# reflect the tables
Base.prepare(engine, reflect=True)

# Save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station

session = scoped_session(sessionmaker(
    autocommit=False, autoflush=False, bind=engine))


@app.route('/')
def home():
    """
        Home page.
        List all routes that are available.
    """
    available_routes = []
    available_routes.append('/api/v1.0/precipitation')
    available_routes.append('/api/v1.0/stations')
    available_routes.append('/api/v1.0/tobs')
    available_routes.append('/api/v1.0/<start>')
    available_routes.append('/api/v1.0/<start>/<end>')

    return jsonify(available_routes)


@app.route('/api/v1.0/precipitation')
def precipitation():
    """
        Convert the query results to a Dictionary using date as the key and prcp as the value.
        Return the JSON representation of your dictionary.
    """
    # Calculate the date 1 year ago from the last data point in the database
    max_date_str = session.scalar(func.max(Measurement.date))
    max_date = dt.datetime.strptime(max_date_str, '%Y-%m-%d').date()
    min_date = max_date + dt.timedelta(days=-365)

    # Perform a query to retrieve the date and precipitation scores
    result = session.query(Measurement.date, Measurement.prcp).\
        filter(Measurement.date <= max_date).\
        filter(Measurement.date >= min_date).\
        all()

    response_dict = {}
    for row in result:
        response_dict[row.date] = row.prcp

    return jsonify(response_dict)


@app.route('/api/v1.0/stations')
def stations():
    """
        Return a JSON list of stations from the dataset.
    """
    active_stations = session.query(Measurement.station, func.count(Measurement.id)).\
    group_by(Measurement.station).\
    order_by(func.count(Measurement.id).desc()).\
    all()
    return jsonify(active_stations)


@app.route('/api/v1.0/tobs')
def tobs():
    """
        Query for the dates and temperature observations from a year from the last data point.
        Return a JSON list of Temperature Observations (tobs) for the previous year.
    """
    # Calculate the date 1 year ago from the last data point in the database
    max_date_str = session.scalar(func.max(Measurement.date))
    max_date = dt.datetime.strptime(max_date_str, '%Y-%m-%d').date()
    min_date = max_date + dt.timedelta(days=-365)

    # Perform a query to retrieve the date and precipitation scores
    result = session.query(Measurement.date, Measurement.tobs).\
        filter(Measurement.date <= max_date).\
        filter(Measurement.date >= min_date).\
        all()

    response_dict = {}
    for row in result:
        response_dict[row.date] = row.tobs

    return jsonify(response_dict)

def daily_normals(date):
    """Daily Normals.
    
    Args:
        date (str): A date string in the format '%m-%d'
        
    Returns:
        A list of tuples containing the daily normals, tmin, tavg, and tmax
    
    """
    
    sel = [func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)]
    return session.query(*sel).filter(func.strftime("%m-%d", Measurement.date) == date).all()
    


@app.route('/api/v1.0/<start>', defaults={'end': None})
@app.route('/api/v1.0/<start>/<end>')
def normals(start, end):
    """
        Return a JSON list of the minimum temperature, the average temperature, and the max temperature for a given start or start-end range.
        When given the start only, calculate TMIN, TAVG, and TMAX for all dates greater than and equal to the start date.
        When given the start and the end date, calculate the TMIN, TAVG, and TMAX for dates between the start and end date inclusive.
    """
    min_date = dt.datetime.strptime(start, '%Y-%m-%d').date()
    if end is None:
        max_date_str = session.scalar(func.max(Measurement.date))
        max_date = dt.datetime.strptime(max_date_str, '%Y-%m-%d').date()
    else:
        max_date = dt.datetime.strptime(end, '%Y-%m-%d').date()

    numdays = max_date - min_date
    date_list = [dt.datetime.strftime(min_date + dt.timedelta(days=x), '%Y-%m-%d') for x in range(0, numdays.days)]
    normals = []
    for date in date_list:
        normals += [(date, ) + daily_normals(date[5:])[0]]
    
    return jsonify(normals)

if __name__ == '__main__':
    app.run(debug=True)