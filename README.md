# GateKeeper Configuration Files

The repository contains skeleton configuration files for the [wcms-gatekeeper](https://github.com/NCIOCPL/wcms-gatekeeper) project.

## Contents

* [Admin](Admin) - config for the GateKeeper administrative UI
* [CDRPreviewWS](CDRPreviewWS) config for the CDR Publish Preview web service
* [ProcMgr](ProcMgr) config for the Process Manager service
* [PromotionTester](PromotionTester) config for the promotion testing tool
* [UnitTest](UnitTest) - config for the NUNIT test suite
* [WebSvc](WebSvc) - config for the GateKeeper web service
* [sharedconfig](sharedconfig) - shared database connection strings.

## Usage

Files in this repository contain placeholders for values which differ between the various environments (e.g. local dev,testing etc.).
To use them, you'll need to obtain/create a substitutions-list file for use with the [text substitution script](tools).
(The text substitution script comes from the [build-tools repository](https://github.com/NCIOCPL/cancergov-build-tools/tree/master/text-substitution),
refer there for the format of the substitutions-list file.)

For each script, run the command

```
powershell -ExecutionPolicy unrestricted tools\substitution.ps1 -InputFile <configfile> -OutputFile <outputname> -SubstituteList <substitutions-list>
```

So to create the Process Manager configurtaion file, using the the wcms-gatekeeper-substitutions.xml file, the command would be

```
powershell -ExecutionPolicy unrestricted tools\substitution.ps1 -InputFile ProcMgr\app.config -OutputFile app.config.procmgr -SubstituteList wcms-gatekeeper-substitutions.xml
```

After running the script, the app.config.procmgr file would be copied to the GateKeeper App/ProcMgr project and renamed to app.config.
