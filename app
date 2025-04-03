from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

from flask import render_template




app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///students.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Database Model
class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    dob = db.Column(db.String(10), nullable=False)
    amount_due = db.Column(db.Float, nullable=False)

with app.app_context():
    db.create_all()

@app.route('/')
def index():
    return render_template('index.html')
    
# Create a new student (POST)
@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()
    new_student = Student(
        first_name=data['first_name'],
        last_name=data['last_name'],
        dob=data['dob'],
        amount_due=data['amount_due']
    )
    db.session.add(new_student)
    db.session.commit()
    return jsonify({'message': 'Student added successfully'}), 201

# Get all students (GET)
@app.route('/students', methods=['GET'])
def get_students():
    students = Student.query.all()
    student_list = [{
        'id': student.id,
        'first_name': student.first_name,
        'last_name': student.last_name,
        'dob': student.dob,
        'amount_due': student.amount_due
    } for student in students]
    return jsonify(student_list)

# Get a single student by ID (GET)
@app.route('/students/<int:id>', methods=['GET'])
def get_student(id):
    student = Student.query.get_or_404(id)
    return jsonify({
        'id': student.id,
        'first_name': student.first_name,
        'last_name': student.last_name,
        'dob': student.dob,
        'amount_due': student.amount_due
    })

# Update a student (PUT)
@app.route('/students/<int:id>', methods=['PUT'])
def update_student(id):
    student = Student.query.get_or_404(id)
    data = request.get_json()
    student.first_name = data.get('first_name', student.first_name)
    student.last_name = data.get('last_name', student.last_name)
    student.dob = data.get('dob', student.dob)
    student.amount_due = data.get('amount_due', student.amount_due)
    db.session.commit()
    return jsonify({'message': 'Student updated successfully'})

# Delete a student (DELETE)
@app.route('/students/<int:id>', methods=['DELETE'])
def delete_student(id):
    student = Student.query.get_or_404(id)
    db.session.delete(student)
    db.session.commit()
    return jsonify({'message': 'Student deleted successfully'})

if __name__ == '__main__':
    app.run(debug=True)
