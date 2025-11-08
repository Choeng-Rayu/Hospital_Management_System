# 🎨 UML Diagrams - Hospital Management System

Complete set of PlantUML diagrams for the Hospital Management System project.

## 📑 Diagram Files

### 1. **class_diagram.puml**
Complete UML class diagram showing:
- **14 Classes**: Person, Patient, Doctor, Nurse, Staff, Administrative, Appointment, Prescription, Medication, Room, Bed, Equipment
- **5 Enums**: RoomType, RoomStatus, BedType, EquipmentStatus, AppointmentStatus
- **All Attributes**: Private fields with visibility indicators
- **All Methods**: Public operations and getters
- **20+ Relationships**: With UML cardinality notation
- **Inheritance Hierarchy**: Person → Staff → Doctor/Nurse/Administrative

**File Size**: ~15 KB
**Complexity**: High (complete system architecture)

---

### 2. **usecase_diagram.puml**
Complete use case diagram showing:
- **5 Actors**: Patient, Doctor, Nurse, Admin, Emergency Staff
- **8 Main Use Cases** (Module categories):
  - Patient Management
  - Doctor Management
  - Appointment Management
  - Prescription Management
  - Room Management
  - Nurse Management
  - Emergency Operations
  - Search Operations
- **33 Total Use Cases**: All features documented
- **Relationships**: Include/extends patterns

**File Size**: ~8 KB
**Complexity**: Medium (feature overview)

---

### 3. **sequence_patient_admission.puml**
Sequence diagram for patient admission flow:
- Admin initiates patient admission
- System validates patient data
- Automatic room assignment
- Database persistence
- Success confirmation

**Participants**: 6
**Steps**: 12 major interactions

---

### 4. **sequence_appointment_scheduling.puml**
Sequence diagram for appointment scheduling:
- Doctor selects appointment creation
- System retrieves patient & doctor info
- Validation of appointment details
- Conflict checking
- Database persistence

**Participants**: 7
**Steps**: 14 major interactions

---

### 5. **sequence_emergency_room_assignment.puml**
Sequence diagram for emergency room assignment:
- Emergency staff initiates emergency assignment
- System retrieves patient information
- Filters for available emergency/ICU rooms
- Assigns available doctor
- Updates patient room assignment

**Participants**: 7
**Steps**: 15 major interactions

---

### 6. **sequence_prescription_creation.puml**
Sequence diagram for prescription creation:
- Doctor creates new prescription
- System retrieves patient with allergies
- Doctor selects medications
- Drug interaction validation
- Persistence and confirmation

**Participants**: 7
**Steps**: 13 major interactions

---

## 🚀 How to Use

### Option 1: Online PlantUML Viewer (Easiest)
1. Visit: http://www.plantuml.com/plantuml/uml/
2. Open any `.puml` file in text editor
3. Copy entire content
4. Paste into left panel of PlantUML editor
5. View rendered diagram on right
6. Export as PNG/SVG

### Option 2: VS Code Extension (Fastest)
1. Install "PlantUML" extension by jebbs
2. Open any `.puml` file in VS Code
3. Right-click → "Preview PlantUML diagram"
4. See diagram render instantly
5. Right-click → "Export as PNG"

### Option 3: Command Line (Advanced)
```bash
# Install plantuml (requires Java)
brew install plantuml        # macOS
apt-get install plantuml     # Linux

# Render diagram
plantuml class_diagram.puml

# Specify output format
plantuml -png class_diagram.puml
plantuml -svg class_diagram.puml
plantuml -pdf class_diagram.puml
```

### Option 4: GitHub Rendering
- Upload `.puml` files to GitHub
- GitHub automatically renders PlantUML in markdown preview
- Can also include in `.md` files with syntax highlighting

---

## 📊 Diagram Complexity

| Diagram | Elements | Relationships | Complexity |
|---------|----------|---------------|----|
| Class | 19 (14 classes + 5 enums) | 20+ | ⭐⭐⭐⭐⭐ |
| Use Case | 38 (5 actors + 33 use cases) | 25+ | ⭐⭐⭐ |
| Patient Admission | 6 participants | 12 steps | ⭐⭐ |
| Appointment Scheduling | 7 participants | 14 steps | ⭐⭐⭐ |
| Emergency Room Assignment | 7 participants | 15 steps | ⭐⭐⭐ |
| Prescription Creation | 7 participants | 13 steps | ⭐⭐⭐ |

---

## 🎯 Key Information

### Class Diagram Highlights
- **Inheritance Chain**: Person → Staff → Doctor/Nurse/Admin
- **Composition**: Room contains Beds, Prescriptions contain Medications
- **Aggregation**: Patient has multiple Doctors, Nurses, Prescriptions
- **Association**: Various relationships with cardinality 0..*, 1, 1..*

### Use Case Diagram Highlights
- **33 Use Cases** covering all system functionality
- **5 Actor Types** with different capabilities
- **8 Feature Categories** organized by module
- **Complete Feature Coverage** documented

### Sequence Diagrams Highlights
- **Clean Architecture Flow**: UI → UseCase → Repository → Database
- **Error Handling**: Validation and conflict detection
- **Data Persistence**: JSON file operations
- **User Feedback**: Success/error messages

---

## 💡 Use Cases

### For Documentation
- Include in thesis/project documentation
- Reference for architecture reviews
- Include in technical specifications

### For Presentations
- Project presentations
- Academic reviews
- Stakeholder demonstrations
- Team discussions

### For Development
- Onboarding new developers
- Architecture discussions
- Feature planning
- Code review reference

### For Quality Assurance
- Test case planning
- System behavior validation
- Edge case identification
- Integration testing

---

## 🔧 Customization

All diagrams are editable. To modify:

1. Open `.puml` file in text editor
2. Edit PlantUML syntax
3. Save file
4. Re-render to see changes

### Common Edits
- Add/remove classes: Modify class definitions
- Change relationships: Edit relationship lines
- Add new methods: Add to class body
- Adjust styling: Modify skinparam settings

---

## 📈 Statistics

### System Coverage
- **Entities**: 14 classes
- **Enumerations**: 5 types
- **Methods**: 150+ total
- **Relationships**: 20+ documented

### Use Cases
- **Modules**: 8 categories
- **Use Cases**: 33 total
- **Actors**: 5 types
- **Features**: 51 operations

### Workflows
- **Sequence Diagrams**: 4 major flows
- **Participants**: 6-7 per flow
- **Steps**: 12-15 per flow
- **Data Interactions**: ~50+ total

---

## ✅ Validation Checklist

- [x] All classes properly documented
- [x] All relationships with cardinality
- [x] All enums defined
- [x] All methods listed
- [x] All use cases included
- [x] All actors identified
- [x] All sequence flows logical
- [x] All syntax valid PlantUML

---

## 🔗 References

### PlantUML Documentation
- **Main Site**: http://plantuml.com/
- **Class Diagram Guide**: http://plantuml.com/class-diagram
- **Use Case Guide**: http://plantuml.com/use-case-diagram
- **Sequence Guide**: http://plantuml.com/sequence-diagram

### Online Tools
- **PlantUML Editor**: http://www.plantuml.com/plantuml/uml/
- **Render Diagram**: http://www.plantuml.com/plantuml/png/

### VS Code Extensions
- **PlantUML**: marketplace.visualstudio.com/items?itemName=jebbs.plantuml

---

## 📝 File Organization

```
UML/
├── README.md                              (This file)
├── class_diagram.puml                     (System architecture)
├── usecase_diagram.puml                   (Features overview)
├── sequence_patient_admission.puml        (Patient workflow)
├── sequence_appointment_scheduling.puml   (Appointment workflow)
├── sequence_emergency_room_assignment.puml (Emergency workflow)
└── sequence_prescription_creation.puml    (Prescription workflow)
```

---

## 🚀 Quick Start

1. **View Class Diagram**
   ```
   Go to: http://www.plantuml.com/plantuml/uml/
   Copy content from class_diagram.puml
   Paste and view
   ```

2. **View Use Cases**
   ```
   Go to: http://www.plantuml.com/plantuml/uml/
   Copy content from usecase_diagram.puml
   Paste and view
   ```

3. **View Sequence Flows**
   ```
   Repeat for any sequence_*.puml file
   ```

4. **Export as PNG**
   ```
   In PlantUML editor: Click "Export" → "PNG"
   Save to your presentation folder
   ```

---

## 🎓 Learning Path

1. **Start with Use Case Diagram**
   - Understand system features
   - Identify actors
   - See feature organization

2. **Study Class Diagram**
   - Learn entity structure
   - Understand relationships
   - See inheritance hierarchy

3. **Review Sequence Diagrams**
   - See how features work
   - Understand data flow
   - Learn workflows

---

## 📞 Support

All files are compatible with:
- ✅ PlantUML Online Editor
- ✅ VS Code Extensions
- ✅ Command-line plantuml
- ✅ GitHub rendering
- ✅ GitLab rendering
- ✅ Confluence integration
- ✅ Jira integration

---

## 🔄 Version Control

These files are version controlled in git:

```bash
git add UML/
git commit -m "Add: Complete UML diagrams in PlantUML format"
git push
```

Keep diagrams updated as system evolves:
- Add classes when entities are added
- Update relationships when they change
- Add use cases for new features
- Add sequence flows for new workflows

---

## 📜 License

These diagrams are part of the Hospital Management System project.

---

*Last Updated: November 6, 2025*
*PlantUML Version: Latest*
*Compatible with: PlantUML Online, VS Code, Command Line*
