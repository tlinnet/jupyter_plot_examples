# Read: https://hub.docker.com/r/jupyter/scipy-notebook/
# Tags: https://hub.docker.com/r/jupyter/scipy-notebook/tags/
# https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook

FROM jupyter/scipy-notebook:033056e6d164

# Set variables    
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

# Set root
USER root

# Get packages
ENV BUILD_PACKAGES="curl wget unzip subversion git"

# Install. # Install all packages in 1 RUN
RUN echo "Installing these packages" $BUILD_PACKAGES
RUN apt-get update && \
    apt-get install --no-install-recommends -y $BUILD_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Set user back
USER ${NB_USER}

#ENV ANACONDA_PACKAGES=""
#conda install -c anaconda $ANACONDA_PACKAGES && \

ENV CONDA_PACKAGES="bqplot"
#conda install -c conda-forge $CONDA_PACKAGES && \

ENV PIP_PACKAGES="nmrglue plotly"
# Convert .py files to .ipynb
ENV PIP_PACKAGES="$PIP_PACKAGES https://github.com/sklam/py2nb/archive/master.zip"
#pip install $PIP_PACKAGES

# RISE: Quickly turn your Jupyter Notebooks into a live presentation.
# datashader: creating meaningful representations of large amounts of data.
# HoloViews: Make data analysis and visualization seamless and simple

# Install packages
RUN echo "" && \
    conda install -c conda-forge $CONDA_PACKAGES && \
    pip install $PIP_PACKAGES && \
    conda install -c damianavila82 rise && \
    conda install -c bokeh datashader && \
    conda install -c ioam holoviews

# jupyter notebook password remove
RUN echo "" && \
    mkdir -p $HOME/.jupyter && \
    cd $HOME/.jupyter && \
    echo "c.NotebookApp.token = u''" > jupyter_notebook_config.py

# Copy examples from: 
# https://github.com/bokeh/bokeh
# https://github.com/bloomberg/bqplot
RUN echo "" && \
    git clone --depth 1 http://github.com/bokeh/bokeh.git && \
    mv bokeh/examples bokeh_examples && \
    rm -rf bokeh && \
    svn export https://github.com/bokeh/datashader/trunk/examples datashader_examples && \
    svn export https://github.com/ioam/holoviews/trunk/examples holoviews_examples && \
    svn export https://github.com/bloomberg/bqplot/trunk/examples bqplot_examples

# Sign Notebooks
#RUN for f in *.ipynb; do jupyter trust $f; done
RUN find . -type f -name '*.ipynb'|while read fname; do echo $fname; jupyter trust "$fname"; done

# Make Jupyter .ipynb notebooks from .ppy files
RUN rm -rf > py_f.txt && \
    find . -type f -name '*.py'|while read fname; do echo "${fname%.*}" >> py_f.txt; done && \
    echo "from py2nb.tools import python_to_notebook; import os.path; import os" > py_f.py && \
    echo "f = open('py_f.txt','r'); li = f.readlines()" >> py_f.py && \
    echo "cdw=os.getcwd()" >> py_f.py && \
    echo "for l in li:" >> py_f.py && \
    echo "    p,f=os.path.split(l.strip())" >> py_f.py && \
    echo "    os.chdir(cdw+os.sep+p)" >> py_f.py && \
    echo "    print(p, f+'.py', f+'.ipynb')" >> py_f.py && \
    echo "    python_to_notebook(f+'.py', f+'.ipynb')" >> py_f.py && \
    python py_f.py

# Possible copy other files to home. ${HOME}
#COPY Dockerfile ${HOME}
#COPY build_Dockerfile.sh ${HOME}

### Set root, and make folder writable
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}