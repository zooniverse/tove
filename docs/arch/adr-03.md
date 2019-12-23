# ADR 03: Azure Data Storage Tools

* Status: Awaiting Review
* Date: Dec 23, 2019

## Context

When a transcription is approved, a set of flat files containing the transcription data will be saved to Azure. Users will have the option to download a zip file containing their requested subject, group, workflow, or project. Depending on the speed at which we are able to zip the necessary files, we will either trigger a direct download, or provide a link to the location of the zip file to the user. 

The goal is to investigate Azure’s storage options (specifically Blob Storage and File Services) and decide which tool is best suited for our needs.

### Factors to consider:

* How easy is it to share a file to the end user? What is the process for this? -Ease of use, how complicated is it to set up, maintain, edit
* access permission features
* Speed of accessing and iterating through files (e.g. getting all files in a given directory)

### Terminology:

**Blob:** acronym for “Binary Large Object”

## Considered Options

* Blob Storage
* File Services

> Azure Files and Azure Blob Storage both offer ways to store large amounts of data in the cloud, but they are useful for slightly different purposes.
>
> Azure Blob Storage is useful for massive-scale, cloud-native applications that need to store unstructured data. To maximize performance and scale, Azure Blob Storage is a simpler storage abstraction than a true file system. You can access Azure Blob Storage only through REST-based client libraries (or directly through the REST-based protocol).
>
> Azure Files is specifically a file system. Azure Files has all the file abstracts that you know and love from years of working with on-premises operating systems. Like Azure Blob Storage, Azure Files offers a REST interface and REST-based client libraries. Unlike Azure Blob Storage, Azure Files offers SMB access to Azure file shares. By using SMB, you can mount an Azure file share directly on Windows, Linux, or macOS, either on-premises or in cloud VMs, without writing any code or attaching any special drivers to the file system. You also can cache Azure file shares on on-premises file servers by using Azure File Sync for quick access, close to where the data is used.

### Option 1: Azure Blob Storage

**Summary:** 
Blob Storage is optimized for storing unstructured data: e.g. information that doesn't reside in a traditional row-column database.

**Specs:**
Target throughput for a single blob is up to 60 MiB per second

Pros:
- Blob Storage has been around for longer (appears to have shipped with the original launch of Azure Web Services in 2010), which means there will be more existing conversation around it (e.g. on stack overflow) and more tools/plugins for working with it
- User reviews present Blob Storage as the go-to option, with File Services being an alternative that is employed for use cases that require specific additional functionality provided by File Services (e.g. mounting onto an existing file server, setting folder-specific permissions)
- Offers a simpler, more basic solution
- Blob Storage is much cheaper than file storage (approximately 1/5 of the cost per unit of data)
- Greater maximum storage size than file storage (2PiB: 1 PiB = 2^50 bytes)

Cons: 
- Azure Active Directory (Microsoft's access management service) permission can only be granted in account level or container level. See [here](https://docs.microsoft.com/en-us/rest/api/storageservices/create-user-delegation-sas) for details. Ultimately, this means that we should only lean choose to use Blob Storage if we expect that clicking on the “data export” option will trigger a download of the zipped file, rather than exposing a link to the file. Triggering a download would make sense if we expect the file retrieval and zipping process to be quick, but at the moment we have no evidence for how long it will take.  

### Option 2: Azure File Service

**Specs:**
Target throughput for a single file share: up to 300 MiB/sec for certain regions, Up to 60 MiB/sec for all regions

Pros: 
- allows for specifying read-only or write-only permissions on folders within the share using a shared access signature
- File Services uses the SMB protocol, which is the same protocol used on file directories on Mac and Windows machines. Therefore a file share can be mapped onto a drive on your machine, which is not possible with a blob container
- Portability: With Blob Storage, if you decide to migrate to a different platform in future, you may have to change your application code. With File storage you can migrate your app to any other platform that supports SMB
- Greater potential throughput

Cons:
- Launched in Sept 2015, hasn't been around for as long as Blob Storage.
- Smaller max size (100 TiB: 1 TiB = 2^40 bytes). We are not expecting to come close to this size, so this isn’t much of a concern

## Decision

The deciding factor ultimately came down to the fact that Azure File Services gives you the option to give a user access to a specific folder rather than the entire file share. Since we do not know for sure that the process of retrieving and zipping the files will happen quickly enough to allow for a direct download of the zip file, we will need to account for the fact that we may need to share the file via a link (which will necessitate setting permissions to access only one specific folder). 

### Links and Articles:
1. [Microsoft: Deciding when to use Azure Blobs, Azure Files, or Azure Disks](https://docs.microsoft.com/en-us/azure/storage/common/storage-decide-blobs-files-disks)
2. [Azure Files FAQ](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-faq) (see ‘Why would I use an Azure file share versus Azure Blob Storage for my data?’) 
3. [Stack Overflow: Blob Storage vs File Service](https://stackoverflow.com/questions/24880430/azure-blob-storage-vs-file-service)
4. [Microsoft: Introducing Azure File Service](https://blogs.msdn.microsoft.com/windowsazurestorage/2014/05/12/introducing-microsoft-azure-file-service/) (scroll to When to use Azure Files vs Azure Blobs vs Azure Disks)
5. [Microsoft: Azure Storage scalability and performance targets for storage accounts](https://docs.microsoft.com/en-us/azure/storage/common/storage-scalability-targets)
6. [Azure Blob Overview](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview)
7. [Azure Blob Introduction](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)