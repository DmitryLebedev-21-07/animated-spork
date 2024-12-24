from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Конфигурация базы данных
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/tv_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Модели таблиц
class Channel(db.Model):
    tablename = 'телеканалы'
    channel_id = db.Column(db.Integer, primary_key=True)
    название_канала = db.Column(db.String(255), nullable=False, unique=True)
    страна_вещания = db.Column(db.String(255), nullable=False)
    контактная_информация = db.Column(db.String(255), nullable=False)
    способы_трансляции = db.Column(db.String(255), nullable=False)

class Program(db.Model):
    tablename = 'телепрограммы'
    program_id = db.Column(db.Integer, primary_key=True)
    название_программы = db.Column(db.String(255), nullable=False, unique=True)
    тип_программы = db.Column(db.String(255), nullable=False)
    жанр = db.Column(db.String(255), nullable=False)
    целевая_аудитория = db.Column(db.String(255), nullable=False)
    канал_id = db.Column(db.Integer, db.ForeignKey('телеканалы.channel_id', ondelete='CASCADE'))

class Episode(db.Model):
    tablename = 'выпуски_программ'
    episode_id = db.Column(db.Integer, primary_key=True)
    дата_и_время = db.Column(db.DateTime, nullable=False, unique=True)
    продолжительность = db.Column(db.Time, nullable=False)
    тематика = db.Column(db.String(255), nullable=False)
    программа_id = db.Column(db.Integer, db.ForeignKey('телепрограммы.program_id', ondelete='CASCADE'))

class Participation(db.Model):
    tablename = 'участие'
    participation_id = db.Column(db.Integer, primary_key=True)
    эпизод = db.Column(db.String(255), nullable=False, unique=True)
    роль = db.Column(db.String(255), nullable=False)
    выпуск_id = db.Column(db.Integer, db.ForeignKey('выпуски_программ.episode_id', ondelete='CASCADE'))

class Participant(db.Model):
    tablename = 'участники'
    participant_id = db.Column(db.Integer, primary_key=True)
    фио = db.Column(db.String(255), nullable=False, unique=True)
    биография = db.Column(db.Text, nullable=False)
    участие_id = db.Column(db.Integer, db.ForeignKey('участие.participation_id', ondelete='CASCADE'))

class Rating(db.Model):
    tablename = 'рейтинги'
    rating_id = db.Column(db.Integer, primary_key=True)
    дата_сбора_данных = db.Column(db.DateTime, nullable=False, unique=True)
    средний_рейтинг = db.Column(db.Integer, nullable=False)
    количество_зрителей = db.Column(db.Integer, nullable=False)
    источник_данных = db.Column(db.String(255), nullable=False)
    канал_id = db.Column(db.Integer, db.ForeignKey('телеканалы.channel_id', ondelete='CASCADE'))

# Маршруты для работы с данными
@app.route('/channels', methods=['POST'])
def add_channel():
    data = request.json
    new_channel = Channel(
        название_канала=data['название_канала'],
        страна_вещания=data['страна_вещания'],
        контактная_информация=data['контактная_информация'],
        способы_трансляции=data['способы_трансляции']
    )
    db.session.add(new_channel)
    db.session.commit()
    return jsonify({"message": "Channel added successfully!"}), 201

@app.route('/channels', methods=['GET'])
def get_channels():
    channels = Channel.query.all()
    return jsonify([{
        "channel_id": channel.channel_id,
        "название_канала": channel.название_канала,
        "страна_вещания": channel.страна_вещания,
        "контактная_информация": channel.контактная_информация,
        "способы_трансляции": channel.способы_трансляции
    } for channel in channels])
@app.route('/programs', methods=['POST'])
def add_program():
    data = request.json
    new_program = Program(
        название_программы=data['название_программы'],
        тип_программы=data['тип_программы'],
        жанр=data['жанр'],
        целевая_аудитория=data['целевая_аудитория'],
        канал_id=data['канал_id']
    )
    db.session.add(new_program)
    db.session.commit()
    return jsonify({"message": "Program added successfully!"}), 201

@app.route('/episodes', methods=['POST'])
def add_episode():
    data = request.json
    new_episode = Episode(
        дата_и_время=data['дата_и_время'],
        продолжительность=data['продолжительность'],
        тематика=data['тематика'],
        программа_id=data['программа_id']
    )
    db.session.add(new_episode)
    db.session.commit()
    return jsonify({"message": "Episode added successfully!"}), 201

@app.route('/participations', methods=['POST'])
def add_participation():
    data = request.json
    new_participation = Participation(
        эпизод=data['эпизод'],
        роль=data['роль'],
        выпуск_id=data['выпуск_id']
    )
    db.session.add(new_participation)
    db.session.commit()
    return jsonify({"message": "Participation added successfully!"}), 201

@app.route('/participants', methods=['POST'])
def add_participant():
    data = request.json
    new_participant = Participant(
        фио=data['фио'],
        биография=data['биография'],
        участие_id=data['участие_id']
    )
    db.session.add(new_participant)
    db.session.commit()
    return jsonify({"message": "Participant added successfully!"}), 201

@app.route('/ratings', methods=['POST'])
def add_rating():
    data = request.json
    new_rating = Rating(
        дата_сбора_данных=data['дата_сбора_данных'],
        средний_рейтинг=data['средний_рейтинг'],
        количество_зрителей=data['количество_зрителей'],
        источник_данных=data['источник_данных'],
        канал_id=data['канал_id']
    )
    db.session.add(new_rating)
    db.session.commit()
    return jsonify({"message": "Rating added successfully!"}), 201

# Запуск приложения
if name == '__main__':
    db.create_all()
    app.run(debug=True)
