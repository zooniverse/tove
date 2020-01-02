# ADR 03: Azure Data Storage Tools

* Status: Awaiting Review
* Date: Dec 23, 2019

## Context

When a transcription is approved, a set of flat files containing the transcription data will be saved to Azure. Users will have the option to download a zip file containing their requested subject, group, workflow, or project. Depending on the speed at which we are able to zip the necessary files, we will either trigger a direct download, or provide a link to the location of the zip file to the user. 

The goal is to investigate Azure’s storage options (specifically Blob Storage and File Services) and decide which tool is best suited for our needs.

### Factors to consider:

* How easy is it to share a file to the end user? What is the process for this?
* Ease of use, how complicated is it to set up, maintain, edit
* access permission features
* Speed of accessing and iterating through files (e.g. getting all files in a given directory)

### Terminology:

**Blob:** acronym for “Binary Large Object”
**Container:** synonym for ”S3 Bucket”
**Shared Access Signature:** similar functionality as “S3 Presigned URLs”

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
- Directory hierarchy system within blob storage is purely virtual - that is, a directory is merely an abstraction over the `/`-delimited names of the underlying container/blob hierarchy. In other words, a virtual directory is a prefix that you apply to a file (blob) name.
- shared access signature permissions can only be granted in account level or container level. See [here](https://docs.microsoft.com/en-us/rest/api/storageservices/create-user-delegation-sas) for details. This means that if we want to provide a link to the file, we will need to create a new blob container for the user so that the user isn't granted access to all transcription data. This may not turn out to be a real "downside" if it turns out there's no overhead involved in creating/deleting containers on demand.

### Option 2: Azure File Service

**Specs:**
Target throughput for a single file share: up to 300 MiB/sec for certain regions, Up to 60 MiB/sec for all regions

Pros: 
- allows for specifying read-only or write-only permissions on folders within the share using a shared access signature (SAS): this would give us more control in how we want to organize/store the generated zip files
- can cache Azure file shares on on-premises file servers by using Azure File Sync for quick access
- File Services uses the SMB protocol, which is the same protocol used on file directories on Mac and Windows machines. Therefore a file share can be mapped onto a drive on your machine, which is not possible with a blob container
- Greater potential throughput

Cons:
- Launched in Sept 2015, hasn't been around for as long as Blob Storage.
- Smaller max size (100 TiB: 1 TiB = 2^40 bytes). We are not expecting to come close to this size, so this isn’t much of a concern

## Decision

While Azure File Service does offer the enticing option of granting folder specific permissions, we don't appear to have any need for the remainder of the additional functionality that comes with File Service, which makes me reluctant to want to use it. In addition, the number of articles and resources available on communicating with Blob Storage to set up file zipping is much greater than what's available for File Service. My initial analysis has not given me any reason to think that setting up user-specific containers would be problematic, but this is an open question worth thinking about for reviewers. Hypothetically, this user-specific container could be deleted after a short time window to avoid organizational clutter and unnecessary additional costs.

Ultimately, my choice is to go with Blob Storage: the more basic, simple storage tool that gives us what we need and nothing more. That being said, I'd still like to keep the option of using Azure File Service on the table, in case it turns out that we *would* benefit from the additional functionality that it offers.

Final questions:
- Blob Storage doesn't have any concrete hierarchy beyond Storage Account/Blob Container - within a container, directories are virtual, demarcated by prefixes in the file name. Will this end up being problematic for us? Will it complicate file retrieval?
- Would there be any benefit to caching files on on-premises file servers? If this sounds like something we'd like to employ, it would be worth reconsidering Azure File Service
- Is there any reason why we might not want to create a new container every time a user wants to download a set of files? It doesn't seem organizationally ideal to me since this would mean that the Tove production storage account would end up cluttered with user-specific folders on the top level of its blob storage, but if we delete them after giving the user a window of time to download, it probably would not get out of hand.

### Links and Articles:
1. [Microsoft: Deciding when to use Azure Blobs, Azure Files, or Azure Disks](https://docs.microsoft.com/en-us/azure/storage/common/storage-decide-blobs-files-disks)
2. [Azure Files FAQ](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-faq) (see ‘Why would I use an Azure file share versus Azure Blob Storage for my data?’) 
3. [Stack Overflow: Blob Storage vs File Service](https://stackoverflow.com/questions/24880430/azure-blob-storage-vs-file-service)
4. [Microsoft: Introducing Azure File Service](https://blogs.msdn.microsoft.com/windowsazurestorage/2014/05/12/introducing-microsoft-azure-file-service/) (scroll to When to use Azure Files vs Azure Blobs vs Azure Disks)
5. [Microsoft: Azure Storage scalability and performance targets for storage accounts](https://docs.microsoft.com/en-us/azure/storage/common/storage-scalability-targets)
6. [Azure Blob Overview](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview)
7. [Azure Blob Introduction](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
