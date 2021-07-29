import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/job_editor.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';

class JobsList extends StatefulWidget {
  // update is a callback which return modified list
  JobsList({Key key, this.originalList, this.typeId, this.add, this.modify, this.remove})
      : super(key: key);

  final List<Job> originalList;
  final String typeId;
  final Function(Job) add;
  final Function(Job, Job) modify;
  final Function(Job) remove;

  @override
  State createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
  List<Job> jobList;

  @override
  void initState() {
    super.initState();
    jobList = widget.originalList;
  }

  void _update() async {
    await Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        jobList = widget.originalList;
      });
      Logger().i('joblist updated ${jobList.map((e) => e.toJson()).toList()}');
    });
  }

  void _openJobEditing(BuildContext context, {Job job}) {
    //assert(jobList.indexOf(job) != -1);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return JobEditorWrapper(
        job: job,
        typeId: widget.typeId,
        onSaved: (newJob) async {
          // Logger().e('Hi Im back with ${newJob.objectName}');
          if (job == null) {
            await widget.add(newJob);
          } else {
            jobList[jobList.indexOf(job)] = newJob;
          }
          _update();
        },
      );
    }));
  }

  void _deleteJob(Job job) async {
    await widget.remove(job);
    _update();
  }

  void _deleteJobPrompt(BuildContext context, Job job) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return AlertDialog(
        title: Text('刪除項目'),
        content: Text('確定刪除項目 ${job.objectName}?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                _deleteJob(job);
                Navigator.of(context).pop();
              },
              child: Text('是')),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('否')),
        ],
      );
    }));
  }

  Text _getSubtitleByState(Job job) {
    switch (job.jobState) {
      case JobState.Empty:
        return Text(JobStateExtension.names[0]);
      case JobState.TBC:
        return Text(JobStateExtension.names[3]);
      case JobState.Included:
        return Text(JobStateExtension.names[4]);
      case JobState.Single:
        return Text(
            '\$${job.pricePerUnit}@1, ${job.amount} ${job.unit}, 總共 \$${job.totalPrice.toStringAsFixed(1)} ');
      case JobState.Multiple:
        return Text(
            '第 ${job.range[0]} 至 ${job.range[1]} 項, 總共 \$${job.pricePerUnit} ');
      default:
        return Text('Error Job State');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          jobList.length != 0
              ? Container(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: jobList.length,
                itemBuilder: (BuildContext context, int index) {
                  Job job = jobList.elementAt(index);
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    child: ListTile(
                      title: Text(job.objectName),
                      subtitle: _getSubtitleByState(job),
                      onTap: () => _openJobEditing(context, job: job),
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: '刪除',
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: () => _deleteJobPrompt(context, job),
                      )
                    ],
                  );
                },
              ))
              : Text('空'),
          ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () => _openJobEditing(context),
          )
        ],
      ),
    );
  }
}
