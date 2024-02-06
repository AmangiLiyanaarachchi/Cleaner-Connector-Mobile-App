import 'package:flutter/material.dart';

class NatureOfInjuryList extends StatefulWidget {
  @override
  _NatureOfInjuryListState createState() => _NatureOfInjuryListState();
}

class _NatureOfInjuryListState extends State<NatureOfInjuryList> {
  List<String> natureOfInjuryList = [
    'Fracture/Dislocation',
    'Dislocation',
    'Sprain/Strain',
    'Internal injury',
    'Amputation',
    'Laceration / Open Wound',
    'Contusion/bruising',
    'Burns',
    'Foreign Body',
    'Absorption via inhalation or digestion',
    'Psychological',
    'Multiple Injuries/Others (give details)',
  ];

  List<bool> isCheckedList = List<bool>.filled(12, false);

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      child: ListView.builder(
         physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: natureOfInjuryList.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(natureOfInjuryList[index]),
            value: isCheckedList[index],
            onChanged: (bool? value) {
              setState(() {
                isCheckedList[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}


class BodyLocation extends StatefulWidget {
  const BodyLocation({super.key});

  @override
  State<BodyLocation> createState() => _BodyLocationState();
}

class _BodyLocationState extends State<BodyLocation> {
   List<String> bodyLocations = [
    'Eye',
    'Ear',
    'Face',
    'Head',
    'Neck',
    'Lower back',
    'Trunk',
    'Shoulders/Arms',
    'Hands/Fingers',
    'Hips/Legs',
    'Feet/Toes',
    'Respiratory system',
    'Psychological (give details)',
  ];


  List<bool> isCheckedList = List<bool>.filled(13, false);

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      child: ListView.builder(
         physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: bodyLocations.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(bodyLocations[index]),
            value: isCheckedList[index],
            onChanged: (bool? value) {
              setState(() {
                isCheckedList[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

class MechanismofInjury extends StatefulWidget {
  @override
  _MechanismofInjuryState createState() => _MechanismofInjuryState();
}

class _MechanismofInjuryState extends State<MechanismofInjury> {
  List<String> MechanismofInjury = [
    'Fall from Height',
    'Slip / trip / fall',
    'Physical strike against or by moving object',
    'Exposure to Noise',
    'Repetitive Movement',
    'Use of equipment (e.g. vibration exposure)',
    'Manual task/s',
    'Exposure to Electricity',
    'Exposure to Heat/Cold',
    'Exposure to Hazardous chemicals or Substances',
    'Aggression in workplace',
    'Ergonomics / workplace design',
    'Others (give details)',
  ];

  List<bool> isCheckedList = List<bool>.filled(13, false);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: MechanismofInjury.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(MechanismofInjury[index]),
            value: isCheckedList[index],
            onChanged: (bool? value) {
              setState(() {
                isCheckedList[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}



class AgencyOfInjuryCheckList extends StatefulWidget {
  @override
  _AgencyOfInjuryCheckListState createState() =>
      _AgencyOfInjuryCheckListState();
}

class _AgencyOfInjuryCheckListState extends State<AgencyOfInjuryCheckList> {
  List<String> agenciesOfInjury = [
    'Machinery Fixed Plant',
    'Mobile Plant',
    'Road Transport',
    'Other Transport',
    'Powered Equip/Tools',
    'Non Power Hand Tools',
    'Non Powered Equip',
    'Chemicals',
    'Other Material/Substance',
    'Outdoor Environment',
    'Indoor Environment',
    'Underground Environment',
    'Others (give details)',
  ];

  List<bool> isCheckedList = List<bool>.filled(13, false);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: agenciesOfInjury.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(agenciesOfInjury[index]),
            value: isCheckedList[index],
            onChanged: (bool? value) {
              setState(() {
                isCheckedList[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

